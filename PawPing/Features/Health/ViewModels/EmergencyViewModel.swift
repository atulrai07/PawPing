//
//  EmergencyViewModel.swift
//  PawPing
//

import Foundation
import Observation
import SwiftUI

@Observable
class EmergencyViewModel {
    
    
    /// The list of available emergency first-aid guides
    private(set) var guides: [EmergencyGuide] = EmergencyStaticData.guides
    
    // MARK: - Dependencies
    
    private var petStore: PetStore?
    private var healthStore: HealthStore?
    
    // MARK: - Initialization
    
    init(petStore: PetStore? = nil, healthStore: HealthStore? = nil) {
        self.petStore = petStore
        self.healthStore = healthStore
    }
    
    func configure(petStore: PetStore, healthStore: HealthStore) {
        self.petStore = petStore
        self.healthStore = healthStore
    }
    
    // MARK: - Actions
    
    /// Triggers a phone call to the standard emergency fallback line
    func initiateEmergencyCall() {
        let phoneString = "tel://100" // Standard fallback line
        
        guard let url = URL(string: phoneString), UIApplication.shared.canOpenURL(url) else {
            print("⚠️ Cannot place call. Simulator or invalid URL: \(phoneString)")
            return
        }
        
        UIApplication.shared.open(url)
    }
}
