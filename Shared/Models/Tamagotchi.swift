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
    var stats: TamagotchiStats

    init(id: UUID = UUID(), name: String, imageSetName: String, stats: TamagotchiStats = TamagotchiStats()) {
        self.id = id
        self.name = name
        self.imageSetName = imageSetName
        self.stats = stats
    }
}

struct TamagotchiStats: Codable {
    var energy: Int
    var fullness: Int
    var happiness: Int

    static let limits = 0...100

    init(energy: Int = 100, fullness: Int = 100, happiness: Int = 100) {
        self.energy = Self.clamp(energy)
        self.fullness = Self.clamp(fullness)
        self.happiness = Self.clamp(happiness)
    }

    mutating func apply(_ effects: ItemEffects) {
        if let energyEffect = effects.energy {
            energy = Self.clamp(energy + energyEffect)
        }
        if let fullnessEffect = effects.fullness {
            fullness = Self.clamp(fullness + fullnessEffect)
        }
        if let happinessEffect = effects.happiness {
            happiness = Self.clamp(happiness + happinessEffect)
        }
    }

    private static func clamp(_ value: Int) -> Int {
        max(limits.lowerBound, min(limits.upperBound, value))
    }
}

struct ItemEffects: Codable {
    let energy: Int?
    let fullness: Int?
    let happiness: Int?

    init(energy: Int? = nil, fullness: Int? = nil, happiness: Int? = nil) {
        self.energy = energy
        self.fullness = fullness
        self.happiness = happiness
    }
}
