//
//  CareStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  Data source for the Care tab — holds lists of vet clinics and day cares.
//  Everything here is mock data for now, will be swapped with real API later.
//

import Foundation
import Observation

// @Observable — same idea as ActivityStore.
// SwiftUI watches every property and re-renders views when something changes.
@Observable
class CareStore {

    var vets: [CareLocation] = []
    var dayCares: [CareLocation] = []

    init() {
        // MARK: - Mock Vets
        // All coordinates placed around Dankaur, Gautam Buddh Nagar, UP (28.42°N, 77.53°E)
        vets = [
            CareLocation(
                id: UUID(), name: "PupiLife Pet Clinic",
                subType: nil,
                rating: 4.8, distance: 1.2, imageName: "profilePhoto",
                latitude: 28.4235, longitude: 77.5310, contactNumber: "91-9876543210",
                email: "contact@pupilife.com", address: "123 Beta Street, Dankaur",
                openingTime: "09:00 AM", closingTime: "08:00 PM",
                petSeen: "850+", experience: "12 Years",
                about: "PupiLife Pet Clinic is a premium center dedicated to advanced pet care. Our specialists bring years of expertise in surgical and diagnostic services, ensuring your pet gets the best treatment available in Dankaur."
            ),
            CareLocation(
                id: UUID(), name: "Samaria Pet Clinic",
                subType: nil,
                rating: 4.8, distance: 2.3, imageName: "profilePhoto",
                latitude: 28.4190, longitude: 77.5280, contactNumber: "91-9876543211",
                email: "hello@samariapet.com", address: "45 Alpha Ave, Dankaur",
                openingTime: "10:00 AM", closingTime: "07:00 PM",
                petSeen: "400+", experience: "4 Years",
                about: "Samaria Pet Clinic offers compassionate care for your furry friends. We specialize in routine checkups, vaccinations, and preventive care in a friendly, low-stress environment."
            ),
            CareLocation(
                id: UUID(), name: "Canine Pet Care",
                subType: nil,
                rating: 4.0, distance: 3.3, imageName: "profilePhoto",
                latitude: 28.4260, longitude: 77.5390, contactNumber: "91-9876543212",
                email: "info@caninecare.com", address: "78 Gamma Blvd, Dankaur",
                openingTime: "08:30 AM", closingTime: "09:00 PM",
                petSeen: "1.2k+", experience: "18 Years",
                about: "Canine Pet Care has been a trusted institution in Dankaur for nearly two decades. We handle everything from minor ailments to complex emergencies with dedicated recovery wards."
            ),
            CareLocation(
                id: UUID(), name: "Ziggly Pet Care",
                subType: nil,
                rating: 3.8, distance: 4.2, imageName: "profilePhoto",
                latitude: 28.4175, longitude: 77.5420, contactNumber: "91-9876543213",
                email: "support@ziggly.com", address: "12 Delta Road, Dankaur",
                openingTime: "09:30 AM", closingTime: "06:30 PM",
                petSeen: "250+", experience: "2 Years",
                about: "Ziggly Pet Care is a modern boutique clinic focused on pet comfort and wellness. We offer state-of-the-art facilities and a personalized touch for every patient."
            ),
            CareLocation(
                id: UUID(), name: "Atulya's Care",
                subType: nil,
                rating: 4.8, distance: 4.8, imageName: "profilePhoto",
                latitude: 28.4150, longitude: 77.5360, contactNumber: "91-9876543214",
                email: "atulya@petcare.com", address: "89 Epsilon Lane, Dankaur",
                openingTime: "24 Hours", closingTime: "24 Hours",
                petSeen: "3k+", experience: "25 Years",
                about: "Atulya's Care is the only 24/7 multispecialty animal hospital in the region. We are equipped with advanced life support and intensive care units for critical care."
            )
        ] // vets

        // MARK: - Mock Day Cares
        dayCares = [
            CareLocation(
                id: UUID(), name: "Paw's Dayout",
                subType: "Pet Boarding Service",
                rating: 4.8, distance: 2.0, imageName: "profilePhoto",
                latitude: 28.4245, longitude: 77.5320, contactNumber: "91-9876543215",
                email: "book@pawsdayout.com", address: "12 Boarding St, Dankaur",
                openingTime: "07:00 AM", closingTime: "08:00 PM",
                petSeen: "150+", experience: "5 Years",
                about: "Paw's Dayout is a luxury boarding service that makes your pet feel right at home. We offer climate-controlled rooms and separate play areas for different dog temperaments."
            ),
            CareLocation(
                id: UUID(), name: "High Paws Home",
                subType: "Pet Boarding Service",
                rating: 4.8, distance: 2.2, imageName: "profilePhoto",
                latitude: 28.4200, longitude: 77.5370, contactNumber: "91-9876543216",
                email: "stay@highpaws.com", address: "34 Playful Ave, Dankaur",
                openingTime: "08:00 AM", closingTime: "08:00 PM",
                petSeen: "500+", experience: "9 Years",
                about: "High Paws Home features spacious yards and round-the-clock caregiver supervision. We provide daily updates to pet parents and prioritize social enrichment for all our guests."
            ),
            CareLocation(
                id: UUID(), name: "Rainer's DayCare",
                subType: "Pet DayCare",
                rating: 4.6, distance: 2.8, imageName: "profilePhoto",
                latitude: 28.4270, longitude: 77.5410, contactNumber: "91-9876543217",
                email: "hello@rainers.com", address: "56 Happy Tails Rd, Dankaur",
                openingTime: "06:30 AM", closingTime: "09:00 PM",
                petSeen: "300+", experience: "3 Years",
                about: "Rainer's DayCare is built on a philosophy of positive reinforcement and structured play. Our team ensures your dog gets exercise, socialization, and rest in equal measure."
            ),
            CareLocation(
                id: UUID(), name: "Scooter's HomeCare",
                subType: "Pet Homecare",
                rating: 4.4, distance: 3.2, imageName: "profilePhoto",
                latitude: 28.4180, longitude: 77.5450, contactNumber: "91-9876543218",
                email: "scooter@homecare.com", address: "78 Pet Friendly Blvd, Dankaur",
                openingTime: "24 Hours", closingTime: "24 Hours",
                petSeen: "100+", experience: "1 Year",
                about: "Scooter's HomeCare provides a safe and quiet haven for pets who prefer a calm environment. Our home-based setting is perfect for older pets or those needing one-on-one attention."
            )
        ] // dayCares
    } // init
} // CareStore
