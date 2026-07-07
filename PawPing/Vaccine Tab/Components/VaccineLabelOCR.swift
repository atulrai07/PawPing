//
//  VaccineLabelOCR.swift
//  PawPing
//
//  Created by Atul on 04/07/26.
//

import UIKit
import Vision

struct ScannedVaccineData {
    var vaccineName: String?
    var manufacturer: String?
    var fullDescription: String?
    var batchNumber: String?
    var expiryDate: Date?
    var rawText: String
}

class VaccineLabelOCR {
    
    /// Performs OCR on the image and parses the text into vaccine fields
    static func performOCR(on image: UIImage) async -> ScannedVaccineData {
        guard let cgImage = image.cgImage else {
            return ScannedVaccineData(rawText: "")
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil else {
                    continuation.resume(returning: ScannedVaccineData(rawText: ""))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: ScannedVaccineData(rawText: ""))
                    return
                }
                
                var lines: [String] = []
                for observation in observations {
                    if let candidate = observation.topCandidates(1).first {
                        lines.append(candidate.string)
                    }
                }
                
                let rawText = lines.joined(separator: "\n")
                let parsedData = self.parseText(lines: lines, rawText: rawText)
                continuation.resume(returning: parsedData)
            }
            
            // Configure request
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try handler.perform([request])
            } catch {
                print("Vision OCR performance error: \(error)")
                continuation.resume(returning: ScannedVaccineData(rawText: ""))
            }
        }
    }
    
    /// Parses OCR recognized text lines into structured vaccine details
    static func parseText(lines: [String], rawText: String) -> ScannedVaccineData {
        var data = ScannedVaccineData(rawText: rawText)
        
        // 1. Identify Vaccine Name & Manufacturer from DB
        data.vaccineName = VaccineDatabase.lookupName(from: rawText)
        data.manufacturer = VaccineDatabase.lookupManufacturer(from: rawText)
        
        // Fallback for vaccine name: if not matched, look for "Vaccine" or common descriptors
        if data.vaccineName == nil {
            for line in lines {
                if line.localizedCaseInsensitiveContains("vaccine") {
                    data.vaccineName = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    break
                }
            }
        }
        
        // Full description could be the line containing "vaccine" or the name itself
        for line in lines {
            if line.contains("CDV-") || line.contains("DHPP") || line.localizedCaseInsensitiveContains("vaccine") {
                data.fullDescription = line.trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        // 2. Extract Batch/Serial Number
        data.batchNumber = extractBatchNumber(lines: lines)
        
        // 3. Extract Expiry Date
        data.expiryDate = extractExpiryDate(lines: lines)
        
        return data
    }
    
    // MARK: - Extractor Helpers
    
    private static func extractBatchNumber(lines: [String]) -> String? {
        // Look for prefixes like SER, Lot, Batch, B.No, L.No
        let lotPrefixes = ["ser", "lot", "batch", "b.no", "l.no", "b/n", "l/n"]
        
        // Pattern to match alphanumeric batch codes (typically 5 to 10 chars, e.g., 8209128, A606A06, A789C01, B011A03)
        // Avoid matching plain short words, focus on codes with letters and digits, or length 6-8 digits
        let batchRegex = "^[A-Z0-9]{5,10}$"
        
        for (index, line) in lines.enumerated() {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for direct label: e.g., "SER 8209128" or "Lot: A606A06"
            for prefix in lotPrefixes {
                if let range = cleanLine.range(of: prefix, options: [.caseInsensitive, .anchored]) {
                    // Extract remainder of line
                    let remainder = cleanLine[range.upperBound...].trimmingCharacters(in: CharacterSet.alphanumerics.inverted.union(.whitespacesAndNewlines))
                    // Ensure the remainder looks like a batch code
                    if remainder.count >= 4 && remainder.count <= 12 {
                        return remainder
                    }
                }
            }
            
            // Sometimes SER, MFG, EXP are labels in a list and the values are listed after, or vice versa
            // e.g. "SER" is line N, and "8209128" is line N+3 or near it.
            // Let's check if current line is exactly a prefix, and search subsequent lines
            let lowercased = cleanLine.lowercased()
            if lotPrefixes.contains(lowercased) {
                // Look ahead 1-4 lines for something matching a batch number regex
                for offset in 1...4 {
                    let nextIndex = index + offset
                    guard nextIndex < lines.count else { break }
                    let candidate = lines[nextIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    if candidate.range(of: batchRegex, options: .regularExpression) != nil {
                        return candidate
                    }
                }
            }
        }
        
        // Fallback: search for any standalone alphanumeric code that fits a typical batch format
        // and doesn't match a date or common label
        for line in lines {
            let candidate = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if candidate.count >= 6 && candidate.count <= 9 {
                // Exclude matches that are obviously dates (e.g. 24 NOV 26, or MM-YYYY)
                if !isDateString(candidate) && candidate.range(of: "^[A-Z0-9]+$", options: .regularExpression) != nil {
                    // Make sure it has at least one digit or letter
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    private static func extractExpiryDate(lines: [String]) -> Date? {
        var expDate: Date? = nil
        let expPrefixes = ["exp", "expiry", "exp.", "expiry date", "valid to"]
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            for prefix in expPrefixes {
                if let range = cleanLine.range(of: prefix, options: [.caseInsensitive]) {
                    let remainder = cleanLine[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                    if let parsed = parseDateString(remainder) {
                        expDate = parsed
                        break
                    }
                }
            }
        }
        
        if expDate == nil {
            var foundDates: [Date] = []
            for line in lines {
                if let parsed = parseDateString(line) {
                    if !foundDates.contains(parsed) {
                        foundDates.append(parsed)
                    }
                }
            }
            
            foundDates.sort()
            expDate = foundDates.last
        }
        
        return expDate
    }
    
    private static func isDateString(_ text: String) -> Bool {
        return parseDateString(text) != nil
    }
    
    /// Parses standard vaccine date string formats: e.g. "24 NOV 26", "09-2026", "09/2026", "30/05/2026"
    static func parseDateString(_ text: String) -> Date? {
        let clean = text.trimmingCharacters(in: CharacterSet.alphanumerics.inverted.union(.whitespacesAndNewlines))
        guard !clean.isEmpty else { return nil }
        
        let formatters = [
            "dd MMM yy",      // 24 NOV 26
            "dd MMM yyyy",    // 24 NOV 2026
            "MM-yyyy",        // 09-2026
            "MM/yyyy",        // 09/2026
            "dd-MM-yyyy",     // 30-05-2026
            "dd/MM/yyyy",     // 30/05/2026
            "dd-MM-yy",       // 30-05-26
            "dd/MM/yy"        // 30/05/26
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in formatters {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: clean) {
                return date
            }
            
            // Try to match partial date within a line (e.g. "EXP 24 NOV 26" -> extract "24 NOV 26")
            // Let's use regex to find substring that matches format
            if format == "dd MMM yy" || format == "dd MMM yyyy" {
                // Matches "24 NOV 26" or "26 MAY 25"
                let datePattern = "\\b\\d{1,2}\\s+[A-Za-z]{3}\\s+\\d{2,4}\\b"
                if let range = clean.range(of: datePattern, options: .regularExpression) {
                    let dateSub = String(clean[range])
                    dateFormatter.dateFormat = format
                    if let date = dateFormatter.date(from: dateSub) {
                        return date
                    }
                }
            } else if format == "MM-yyyy" || format == "MM/yyyy" {
                // Matches "09-2026" or "09/2026"
                let datePattern = "\\b\\d{2}[-/]\\d{4}\\b"
                if let range = clean.range(of: datePattern, options: .regularExpression) {
                    let dateSub = String(clean[range])
                    dateFormatter.dateFormat = format
                    if let date = dateFormatter.date(from: dateSub) {
                        return date
                    }
                }
            }
        }
        
        return nil
    }
}
