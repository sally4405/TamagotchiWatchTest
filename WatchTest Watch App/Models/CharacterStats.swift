//
//  CharacterStats.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/21/25.
//

import Foundation

@MainActor
class CharacterStats: ObservableObject {
    private let defaults: UserDefaults
    
    private enum Keys {
        static let energy = "character_energy"
        static let fullness = "character_fullness"
        static let happiness = "character_happiness"
    }
    
    private enum Limits {
        static let min = 0
        static let max = 100
    }
    
    @Published var energy: Int {
        didSet { saveData() }
    }
    
    @Published var fullness: Int {
        didSet { saveData() }
    }
    
    @Published var happiness: Int {
        didSet { saveData() }
    }
    
    init() {
        self.defaults = UserDefaults(suiteName: "group.com.example.watchtest") ?? .standard
        
        if defaults.object(forKey: Keys.energy) == nil {
            self.energy = Limits.max
            self.fullness = Limits.max
            self.happiness = Limits.max
            saveData()
        } else {
            self.energy = defaults.integer(forKey: Keys.energy)
            self.fullness = defaults.integer(forKey: Keys.fullness)
            self.happiness = defaults.integer(forKey: Keys.happiness)
        }
    }
    
    func applyItem(effects: ItemEffects) {
        if let energyEffect = effects.energy {
            energy = clamp(energy + energyEffect)
        }
        if let fullnessEffect = effects.fullness {
            fullness = clamp(fullness + fullnessEffect)
        }
        if let happinessEffect = effects.happiness {
            happiness = clamp(happiness + happinessEffect)
        }
    }
    
    private func saveData() {
        defaults.set(energy, forKey: Keys.energy)
        defaults.set(fullness, forKey: Keys.fullness)
        defaults.set(happiness, forKey: Keys.happiness)
    }
    
    private func clamp(_ value: Int) -> Int {
        return max(Limits.min, min(Limits.max, value))
    }
}

struct ItemEffects: Codable {
    let energy: Int?
    let fullness: Int?
    let happiness: Int?
}
