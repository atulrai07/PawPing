//
//  SupabaseConfig.swift
//  PawPing
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://xvehkasclpwlihskjrhb.supabase.co")!
    static let key = "sb_publishable_3o5SLAWIiP73uJhdyuOhWg_MT6ugVcm"
    
    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: key
    )
}
