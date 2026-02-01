//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation
struct Profile {
    var dogName: String
    var breed: String
    var gender : String
    var age : String
    var dogImage: String = "profilePhoto"
}

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int
    
    // Helper to calculate progress (0.0 to 1.0)
    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}
