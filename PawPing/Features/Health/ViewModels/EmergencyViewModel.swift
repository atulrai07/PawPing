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
    
    // MARK: - Computed Properties
    
    /// Returns the primary vet's phone number from the pet's records if available
    var primaryVetPhone: String? {
        guard let healthStore = healthStore else { return nil }
        
        // Find the first vaccine record that has a vet phone number
        let recordWithPhone = healthStore.healthRecords.first { record in
            guard let phone = record.vetPhone else { return false }
            return !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return recordWithPhone?.vetPhone
    }
    
    /// Returns the primary vet's name if available
    var primaryVetName: String? {
        guard let healthStore = healthStore else { return nil }
        let recordWithVet = healthStore.healthRecords.first { $0.vetName != nil }
        return recordWithVet?.vetName
    }
    
    // MARK: - Actions
    
    /// Triggers a phone call to the primary vet, or falls back to standard emergency prompt if nil
    func initiateEmergencyCall() {
        let phoneString: String
        
        if let vetPhone = primaryVetPhone {
            // Clean up string to leave only digits
            let digitsOnly = vetPhone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            phoneString = "tel://\(digitsOnly)"
        } else {
            // Fallback emergency vet number (can be configured or open dialer with standard emergency services)
            // Using placeholder standard line
            phoneString = "tel://100" // Standard fallback
        }
        
        guard let url = URL(string: phoneString), UIApplication.shared.canOpenURL(url) else {
            print("⚠️ Cannot place call. Simulator or invalid URL: \(phoneString)")
            return
        }
        
        UIApplication.shared.open(url)
    }
}
