//
//  VaccineDatabase.swift
//  PawPing
//
//  Created by Antigravity on 04/07/26.
//

import Foundation

struct VaccineDatabase {
    static let nameMapping: [(pattern: String, displayName: String)] = [
        ("dapp", "DHPP Booster"),
        ("dhpp", "DHPP Booster"),
        ("dhp", "DHPP Booster"),
        ("dhppi", "DHPP Booster"),
        ("cdv-cav2-cpiv-cpv", "DHPP Booster"),
        ("canine coronavirus", "Canine Coronavirus"),
        ("canine cv", "Canine Coronavirus"),
        ("rabies", "Rabies Annual"),
        ("defensor", "Rabies Annual"),
        ("nobivac dhppi", "DHPP Booster"),
        ("nobivac dhpp", "DHPP Booster"),
        ("nobivac rabies", "Rabies Annual"),
        ("nobivac 1-rabies", "Rabies Annual"),
        ("bordetella", "Bordetella"),
        ("bronchyshield", "Bordetella"),
        ("leptospirosis", "Leptospirosis"),
        ("lepto", "Leptospirosis"),
        ("l4", "Leptospirosis"),
        ("parvovirus", "Parvovirus Booster"),
        ("distemper", "Distemper Booster"),
        ("nobivac", "Nobivac Vaccine")
    ]
    
    /// Maps label text fragments (case-insensitive) to vaccine manufacturer names
    static let manufacturerMapping: [(pattern: String, displayName: String)] = [
        ("zoetis", "Zoetis"),
        ("vanguard", "Zoetis"),
        ("nobivac", "MSD Animal Health"),
        ("msd", "MSD Animal Health"),
        ("merial", "Boehringer Ingelheim"),
        ("boehringer", "Boehringer Ingelheim"),
        ("elanco", "Elanco"),
        ("intervet", "MSD Animal Health"),
        ("virbac", "Virbac")
    ]
    
    /// Looks up a friendly name based on raw OCR text
    static func lookupName(from rawText: String) -> String? {
        let lowercased = rawText.lowercased()
        let sortedMapping = nameMapping.sorted { $0.pattern.count > $1.pattern.count }
        for mapping in sortedMapping {
            if lowercased.contains(mapping.pattern) {
                return mapping.displayName
            }
        }
        return nil
    }
    
    /// Looks up a manufacturer based on raw OCR text
    static func lookupManufacturer(from rawText: String) -> String? {
        let lowercased = rawText.lowercased()
        let sortedMapping = manufacturerMapping.sorted { $0.pattern.count > $1.pattern.count }
        for mapping in sortedMapping {
            if lowercased.contains(mapping.pattern) {
                return mapping.displayName
            }
        }
        return nil
    }
}
