//
//  SupabaseConfig.swift
//  PawPing
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://rraykjkvtjjralhrezvr.supabase.co")!
    static let key = "sb_publishable_pQyp0PCfR9xpRHxDE0S6LA_RYWOhyey"
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            // Try yyyy-MM-dd (Postgres DATE)
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            // Try ISO8601 (Postgres TIMESTAMPTZ)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }
        return decoder
    }
    
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }
    
    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: key,
        options: SupabaseClientOptions(
            db: .init(encoder: encoder, decoder: decoder),
            auth: .init(emitLocalSessionAsInitialSession: true)
        )
    )
}
