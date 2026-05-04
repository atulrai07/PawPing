//
//  HealthReportConfig.swift
//  PawPing
//
//  Created by Atul on 28/04/26.
//

import Foundation

struct HealthReportConfig: Equatable {
    var includeVaccinations: Bool = true
    var includeDeworming: Bool = true
    var includeMedications: Bool = false
    var includeLabResults: Bool = false
    var includeWeightChart: Bool = true
    var includeDietPlan: Bool = true
}
