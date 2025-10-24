//
//  CharacterStats.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/21/25.
//

import Foundation

enum CharacterState: String, Codable {
    case idle
    case sleeping
}

@MainActor
class CharacterStats: ObservableObject {
    private let defaults: UserDefaults
    private var stateTimer: Timer?
    
    private enum Keys {
        static let energy = "character_energy"
        static let fullness = "character_fullness"
        static let happiness = "character_happiness"
        static let state = "character_state"
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
    
    @Published var currentState: CharacterState {
        didSet { saveData() }
    }
    
    init() {
        self.defaults = UserDefaults(suiteName: "group.com.sello.watchtest") ?? .standard
        
        if defaults.object(forKey: Keys.energy) == nil {
            //            self.energy = Limits.max
            //            self.fullness = Limits.max
            //            self.happiness = Limits.max
            self.energy = 20
            self.fullness = 30
            self.happiness = 0
            self.currentState = .idle
            saveData()
        } else {
            self.energy = defaults.integer(forKey: Keys.energy)
            self.fullness = defaults.integer(forKey: Keys.fullness)
            self.happiness = defaults.integer(forKey: Keys.happiness)
            
            if let stateString = defaults.string(forKey: Keys.state),
               let state = CharacterState(rawValue: stateString) {
                self.currentState = state
            } else {
                self.currentState = .idle
            }
        }
        
        if currentState == .sleeping {
            startTimer()
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
    
    func startSleeping() {
        guard currentState == .idle else { return }
        currentState = .sleeping
        startTimer()
    }
    
    func wakeUp() {
        currentState = .idle
        stopTimer()
    }
    
    private func startTimer() {
        stopTimer()
        stateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.applyStateEffects()
            }
        }
    }
    
    private func stopTimer() {
        stateTimer?.invalidate()
        stateTimer = nil
    }
    
    private func applyStateEffects() {
        switch currentState {
        case .idle:
            break
        case .sleeping:
            energy = clamp(energy + 1)
            fullness = clamp(fullness - 1)
            
            if energy >= Limits.max || fullness <= Limits.min {
                wakeUp()
            }
        }
    }
    
    private func saveData() {
        defaults.set(energy, forKey: Keys.energy)
        defaults.set(fullness, forKey: Keys.fullness)
        defaults.set(happiness, forKey: Keys.happiness)
        defaults.set(currentState.rawValue, forKey: Keys.state)
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
