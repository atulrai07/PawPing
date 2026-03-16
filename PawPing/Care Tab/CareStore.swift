//
//  CareStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//


import Foundation

@Observable
class CareStore {

    var vets: [CareLocation] = []
    var dayCares: [CareLocation] = []

    init() {
        vets = [
            CareLocation(
                id: UUID(), name: "Pupi Pet Life", rating: 4.3, distance: 2.3,
                imageName: "profileImage", latitude: 28.522211, longitude: 77.215489,
                contactNumber: "6430297691", email: "samplemails@gmail.com",
                address: "n/a", openingTime: "10:30AM", closingTime: "10:30PM"
            ),
            CareLocation(
                id: UUID(), name: "Vet 2", rating: 3.3, distance: 1.3,
                imageName: "profileImage", latitude: 28.79222, longitude: 76.2123334,
                contactNumber: "3430212391", email: "samplemails@gmail.com",
                address: "n/a", openingTime: "10:30AM", closingTime: "10:30PM"
            )
        ]

        dayCares = [
            CareLocation(
                id: UUID(), name: "Mamoon's Day Care", subType: "Pet Restraunt",
                rating: 4.6, distance: 1.2, imageName: "profileImage",
                latitude: 28.5222111, longitude: 77.2122322, contactNumber: "01712345678",
                email: "mamoon@example.com", address: "123 Main St, Anytown, USA",
                openingTime: "09:00 AM", closingTime: "05:00 PM"
            ),
            CareLocation(
                id: UUID(), name: "Paws & Claws", subType: "Pet Shelter",
                rating: 4.0, distance: 2.5, imageName: "profileImage",
                latitude: 28.1211, longitude: 76.6767, contactNumber: "01712345678",
                email: "paws@example.com", address: "456 Elm St, Anytown, USA",
                openingTime: "08:00 AM", closingTime: "06:00 PM"
            )
        ]
    }
}
