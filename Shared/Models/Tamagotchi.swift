//
//  Tamagotchi.swift
//  WatchTest
//
//  Created by sello.axz on 11/3/25.
//

import Foundation

struct Tamagotchi: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageSetName: String
    var energy: Int
    var fullness: Int
    var happiness: Int
    
    init(name: String, imageSetName: String) {
        self.id = UUID()
        self.name = name
        self.imageSetName = imageSetName
        self.energy = 100
        self.fullness = 100
        self.happiness = 100
    }
}
