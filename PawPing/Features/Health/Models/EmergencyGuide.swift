//
//  EmergencyGuide.swift
//  PawPing
//

import Foundation
import SwiftUI

// MARK: - Emergency SOP Model

struct EmergencyGuide: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let symptoms: [String]
    let steps: [String]
    let warning: String?
    let videoID: String?
}


// MARK: - Static Data

enum EmergencyStaticData {
    static let guides: [EmergencyGuide] = [
        EmergencyGuide(
            title: "CPR (Heart Stop)",
            icon: "heart.text.square.fill",
            color: Color("baseColor"),
            symptoms: [
                "Unconscious and unresponsive",
                "No visible breathing (chest not rising)",
                "Gums are pale or blue/grey"
            ],
            steps: [
                "Lay the dog on their right side on a flat surface.",
                "Check the airway for obstructions. Pull the tongue forward.",
                "Place your hands over the widest part of the chest (for deep-chested dogs) or directly over the heart (for flat-chested/small dogs).",
                "Compress chest by 1/3 to 1/2 of its width at a rate of 100 to 120 compressions per minute.",
                "If alone: Perform 30 compressions followed by 2 quick breaths into the dog's nose (hold their muzzle closed). Repeat cycle."
            ],
            warning: "Do NOT perform CPR on a healthy, conscious dog as it can cause serious injury.",
            videoID: "KqClwoUrgZA" // PDSA Pet First Aid CPR
        ),
        EmergencyGuide(
            title: "Choking",
            icon: "lungs.fill",
            color: Color("baseColor"),
            symptoms: [
                "Frantic pawing at the mouth",
                "Gagging, coughing, or gasping",
                "Blue gums or tongue"
            ],
            steps: [
                "Restrain the dog carefully. Open their mouth to inspect the throat using a flashlight.",
                "If you can see the object clearly, try to swipe it out with your fingers. Do NOT push it deeper.",
                "If object cannot be reached, perform Heimlich maneuver: Stand behind the dog, wrap your arms around their abdomen behind the ribcage.",
                "Apply 5 quick, upward thrusts under the ribs, then check their mouth again.",
                "For small dogs, hold them head-down with their back against your chest and apply pressure under the ribs."
            ],
            warning: "Be extremely careful. A choking dog is in panic and is highly likely to bite out of fear.",
            videoID: "u1mVw3BaBMo" // Pet First Aid Choking
        ),
        EmergencyGuide(
            title: "Poison Ingestion",
            icon: "exclamationmark.triangle.fill",
            color: Color("baseColor"),
            symptoms: [
                "Vomiting, diarrhea, or excessive drooling",
                "Seizures or sudden tremors",
                "Lethargy or loss of consciousness"
            ],
            steps: [
                "Immediately identify the substance ingested (chocolate, grapes, detergent, medications).",
                "Collect the packaging or sample of the poison if safe to do so.",
                "Contact your vet or Poison Control instantly with details of what, when, and how much they ate.",
                "Keep the dog calm. Do NOT induce vomiting unless specifically instructed by a veterinarian.",
                "Never give home remedies (like oil or milk) as they can speed up poison absorption."
            ],
            warning: "Inducing vomiting for corrosive substances (bleach, batteries) will cause severe burn damage to the esophagus.",
            videoID: "S18UxMuBUb8"
        ),
        EmergencyGuide(
            title: "Heat Stroke",
            icon: "sun.max.fill",
            color: Color("baseColor"),
            symptoms: [
                "Heavy, loud, or frantic panting",
                "Bright red gums and thick saliva",
                "Weakness, staggering, or collapse"
            ],
            steps: [
                "Move the dog to a cool, shaded area with a fan immediately.",
                "Pour cool (never freezing/ice) water over their head, body, and paws. Or drape cool, wet towels over them.",
                "Offer fresh, cool drinking water. Do NOT force them to drink.",
                "Monitor their temperature if possible. Stop cooling efforts once body temp drops to 39.5°C (103°F).",
                "Take them to the vet immediately. Heat stroke causes silent, delayed organ failure."
            ],
            warning: "Do NOT use ice or freezing water. It constricts blood vessels, trapping heat inside their vital organs.",
            videoID: "Et80ZrwOYMM" // Heatstroke in dogs
        ),
        EmergencyGuide(
            title: "Bleeding & Wounds",
            icon: "drop.fill",
            color: Color("baseColor"),
            symptoms: [
                "Active blood dripping or spurting",
                "Deep lacerations or puncture wounds",
                "Dog constantly licking a painful area"
            ],
            steps: [
                "Place a clean, dry cloth or sterile gauze directly over the bleeding wound.",
                "Apply firm, continuous pressure for at least 3 to 5 minutes. Do NOT lift the cloth to check.",
                "If blood soaks through, add another layer of cloth on top. Do NOT remove the original layer.",
                "If bleeding is on a limb, gently elevate it above the heart while maintaining pressure.",
                "Secure the dressing with bandage wrap, ensuring it's not too tight to cut off circulation."
            ],
            warning: "Do NOT apply a tourniquet unless you are instructed by a vet, as it can result in limb amputation.",
            videoID: "CjsJBrzFHhs" // Dog bleeding first aid
        )
    ]
}
