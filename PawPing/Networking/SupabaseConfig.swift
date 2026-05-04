//
//  SupabaseConfig.swift
//  PawPing
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://xvehkasclpwlihskjrhb.supabase.co")!
    static let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2ZWhrYXNjbHB3bGloc2tqcmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyNzMyMzAsImV4cCI6MjA5Mjg0OTIzMH0.3GjhT50C89c9D20xOpjQifrZBF8n24eZJAzlfIzxBCU"
    
    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: key,
        options: .init(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
    
    // Used exclusively to bypass Storage RLS since the user is unable to run SQL right now.
    static let serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2ZWhrYXNjbHB3bGloc2tqcmhiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzI3MzIzMCwiZXhwIjoyMDkyODQ5MjMwfQ.RVcPbwiG-M-KFny9Oh2anncc0Syy6JMkJmj7mZ9WGaU"
    static let storageClient = SupabaseClient(
        supabaseURL: url,
        supabaseKey: serviceRoleKey
    )
}
