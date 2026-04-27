//
//  SymptomModel.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  Data model for individual symptoms the user can select.
//  Each symptom belongs to a category and may be flagged as emergency-level.
//

import Foundation

// MARK: - Symptom

struct Symptom: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SymptomCategory
    let isEmergency: Bool
}

// MARK: - Symptom Category

enum SymptomCategory: String, CaseIterable, Identifiable {
    case digestive       = "Digestive"
    case skin            = "Skin & Coat"
    case respiratory     = "Respiratory"
    case neurological    = "Neurological"
    case general         = "General"
    case musculoskeletal = "Movement"
    case urinary         = "Urinary"
    case eyesEars        = "Eyes & Ears"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .digestive:      return "stomach"
        case .skin:           return "allergens"
        case .respiratory:    return "lungs"
        case .neurological:   return "brain.head.profile"
        case .general:        return "heart.text.clipboard"
        case .musculoskeletal: return "figure.walk"
        case .urinary:        return "drop"
        case .eyesEars:       return "eye"
        }
    }
    
    var description: String {
        switch self {
        case .digestive:      return "Vomiting, diarrhea, or appetite"
        case .skin:           return "Itching, redness, or hair loss"
        case .respiratory:    return "Coughing, panting, or sneezing"
        case .neurological:   return "Seizures, shaking, or balance"
        case .general:        return "Fever, lethargy, or pain"
        case .musculoskeletal: return "Limping, stiffness, or weakness"
        case .urinary:        return "Peeing issues or drinking changes"
        case .eyesEars:       return "Discharge, redness, or scratching"
        }
    }
}

// MARK: - Master Symptom Catalog

extension Symptom {
    static let catalog: [Symptom] = [
        // Digestive
        Symptom(id: "vomiting", name: "Vomiting", category: .digestive, isEmergency: false),
        Symptom(id: "diarrhea", name: "Diarrhea", category: .digestive, isEmergency: false),
        Symptom(id: "bloody_diarrhea", name: "Bloody Diarrhea", category: .digestive, isEmergency: true),
        Symptom(id: "loss_of_appetite", name: "Loss of Appetite", category: .digestive, isEmergency: false),
        Symptom(id: "abdominal_pain", name: "Abdominal Pain", category: .digestive, isEmergency: false),
        Symptom(id: "swollen_abdomen", name: "Swollen Abdomen", category: .digestive, isEmergency: true),
        Symptom(id: "retching_without_vomiting", name: "Retching Without Vomiting", category: .digestive, isEmergency: true),
        Symptom(id: "gas", name: "Gas / Flatulence", category: .digestive, isEmergency: false),
        Symptom(id: "bloated_belly", name: "Bloated Belly", category: .digestive, isEmergency: false),
        Symptom(id: "visible_worms_in_stool", name: "Visible Worms in Stool", category: .digestive, isEmergency: false),
        Symptom(id: "scooting", name: "Scooting", category: .digestive, isEmergency: false),
        Symptom(id: "difficulty_eating", name: "Difficulty Eating", category: .digestive, isEmergency: false),
        Symptom(id: "hunched_posture", name: "Hunched Posture", category: .digestive, isEmergency: false),

        // Skin & Coat
        Symptom(id: "excessive_scratching", name: "Excessive Scratching", category: .skin, isEmergency: false),
        Symptom(id: "hair_loss", name: "Hair Loss", category: .skin, isEmergency: false),
        Symptom(id: "red_bumps_on_skin", name: "Red Bumps on Skin", category: .skin, isEmergency: false),
        Symptom(id: "hot_spots", name: "Hot Spots", category: .skin, isEmergency: false),
        Symptom(id: "chewing_at_skin", name: "Chewing at Skin", category: .skin, isEmergency: false),
        Symptom(id: "dry_skin", name: "Dry / Flaky Skin", category: .skin, isEmergency: false),

        // Respiratory
        Symptom(id: "persistent_cough", name: "Persistent Cough", category: .respiratory, isEmergency: false),
        Symptom(id: "coughing", name: "Coughing", category: .respiratory, isEmergency: false),
        Symptom(id: "sneezing", name: "Sneezing", category: .respiratory, isEmergency: false),
        Symptom(id: "runny_nose", name: "Runny Nose", category: .respiratory, isEmergency: false),
        Symptom(id: "rapid_breathing", name: "Rapid Breathing", category: .respiratory, isEmergency: false),
        Symptom(id: "excessive_panting", name: "Excessive Panting", category: .respiratory, isEmergency: false),

        // Neurological
        Symptom(id: "seizures", name: "Seizures", category: .neurological, isEmergency: true),
        Symptom(id: "tremors", name: "Tremors", category: .neurological, isEmergency: true),
        Symptom(id: "uncoordinated_movement", name: "Uncoordinated Movement", category: .neurological, isEmergency: true),
        Symptom(id: "collapse", name: "Collapse", category: .neurological, isEmergency: true),

        // General
        Symptom(id: "lethargy", name: "Lethargy", category: .general, isEmergency: false),
        Symptom(id: "fever", name: "Fever", category: .general, isEmergency: false),
        Symptom(id: "dehydration", name: "Dehydration", category: .general, isEmergency: false),
        Symptom(id: "weight_loss", name: "Weight Loss", category: .general, isEmergency: false),
        Symptom(id: "weight_gain", name: "Unexplained Weight Gain", category: .general, isEmergency: false),
        Symptom(id: "drooling", name: "Excessive Drooling", category: .general, isEmergency: false),
        Symptom(id: "restlessness", name: "Restlessness", category: .general, isEmergency: false),
        Symptom(id: "cold_intolerance", name: "Cold Intolerance", category: .general, isEmergency: false),
        Symptom(id: "bad_breath", name: "Bad Breath", category: .general, isEmergency: false),
        Symptom(id: "swollen_lymph_nodes", name: "Swollen Lymph Nodes", category: .general, isEmergency: false),
        Symptom(id: "bleeding_gums", name: "Bleeding Gums", category: .general, isEmergency: false),
        Symptom(id: "pawing_at_mouth", name: "Pawing at Mouth", category: .general, isEmergency: false),
        Symptom(id: "bright_red_gums", name: "Bright Red Gums", category: .general, isEmergency: true),

        // Movement
        Symptom(id: "limping", name: "Limping", category: .musculoskeletal, isEmergency: false),
        Symptom(id: "difficulty_standing", name: "Difficulty Standing", category: .musculoskeletal, isEmergency: false),
        Symptom(id: "reluctance_to_exercise", name: "Reluctance to Exercise", category: .musculoskeletal, isEmergency: false),
        Symptom(id: "bunny_hopping_gait", name: "Bunny Hopping Gait", category: .musculoskeletal, isEmergency: false),
        Symptom(id: "stiffness", name: "Stiffness", category: .musculoskeletal, isEmergency: false),
        Symptom(id: "licking_joints", name: "Licking Joints", category: .musculoskeletal, isEmergency: false),

        // Urinary
        Symptom(id: "frequent_urination", name: "Frequent Urination", category: .urinary, isEmergency: false),
        Symptom(id: "straining_to_urinate", name: "Straining to Urinate", category: .urinary, isEmergency: false),
        Symptom(id: "bloody_urine", name: "Bloody Urine", category: .urinary, isEmergency: true),
        Symptom(id: "whimpering_while_urinating", name: "Whimpering While Urinating", category: .urinary, isEmergency: false),
        Symptom(id: "licking_genital_area", name: "Licking Genital Area", category: .urinary, isEmergency: false),

        // Eyes & Ears
        Symptom(id: "ear_scratching", name: "Ear Scratching", category: .eyesEars, isEmergency: false),
        Symptom(id: "head_shaking", name: "Head Shaking", category: .eyesEars, isEmergency: false),
        Symptom(id: "ear_odor", name: "Ear Odor", category: .eyesEars, isEmergency: false),
        Symptom(id: "ear_discharge", name: "Ear Discharge", category: .eyesEars, isEmergency: false),
        Symptom(id: "redness_in_ear", name: "Redness in Ear", category: .eyesEars, isEmergency: false),
        Symptom(id: "eye_discharge", name: "Eye Discharge", category: .eyesEars, isEmergency: false),
        Symptom(id: "red_eyes", name: "Red Eyes", category: .eyesEars, isEmergency: false),
        Symptom(id: "squinting", name: "Squinting", category: .eyesEars, isEmergency: false),
        Symptom(id: "watery_eyes", name: "Watery Eyes", category: .eyesEars, isEmergency: false),
        Symptom(id: "pawing_at_eyes", name: "Pawing at Eyes", category: .eyesEars, isEmergency: false),
    ]
}
