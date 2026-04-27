//
//  BreedTrait.swift
//  PawPing
//

import Foundation

struct BreedTrait: Codable, Identifiable {
    var id: String { breed }
    let breed: String
    let affectionateWithFamily: Int
    let goodWithYoungChildren: Int
    let goodWithOtherDogs: Int
    let sheddingLevel: Int
    let coatGroomingFrequency: Int
    let droolingLevel: Int
    let coatType: String
    let coatLength: String
    let opennessToStrangers: Int
    let playfulnessLevel: Int
    let watchdogNature: Int
    let adaptabilityLevel: Int
    let trainabilityLevel: Int
    let energyLevel: Int
    let barkingLevel: Int
    let mentalStimulationNeeds: Int
}

struct TraitDescription: Identifiable {
    var id: String { trait }
    let trait: String
    let lowLabel: String
    let highLabel: String
    let description: String
}