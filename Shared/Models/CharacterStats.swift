//
//  CharacterStats.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/21/25.
//

import Foundation

@MainActor
protocol CharacterStatsDelegate: AnyObject {
    func characterStatsDidUpdate(id: UUID, energy: Int, fullness: Int, happiness: Int)
}

enum CharacterState: String, Codable {
    case idle
    case sleeping
}

@MainActor
class CharacterStats: ObservableObject {
    weak var delegate: CharacterStatsDelegate?
    private let defaults: UserDefaults
    private var stateTimer: Timer?
    
    private enum Limits {
        static let min = 0
        static let max = 100
    }
    
    @Published var selectedTamagotchiId: UUID?
    @Published var imageSetName: String = "Character1"
    
    @Published var energy: Int {
        didSet { saveData() }
    }
    
    @Published var fullness: Int {
        didSet { saveData() }
    }
    
    @Published var happiness: Int {
        didSet { saveData() }
    }
    
    @Published var currentState: CharacterState = .idle
    
    init() {
        self.defaults = UserDefaults(suiteName: AppGroup.suiteName) ?? .standard

        if let idString = defaults.string(forKey: AppGroupKeys.selectedId),
           let id = UUID(uuidString: idString) {
            selectedTamagotchiId = id
            imageSetName = defaults.string(forKey: AppGroupKeys.selectedImageSetName) ?? "Character1"
            energy = defaults.integer(forKey: AppGroupKeys.selectedEnergy)
            fullness = defaults.integer(forKey: AppGroupKeys.selectedFullness)
            happiness = defaults.integer(forKey: AppGroupKeys.selectedHappiness)
        } else {
            selectedTamagotchiId = nil
            energy = Limits.max
            fullness = Limits.max
            happiness = Limits.max
        }
        
        currentState = .idle
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
    
    // WatchConnectivity로 받은 다마고치 로드
    func loadTamagotchi(id: UUID, imageSetName: String, energy: Int, fullness: Int, happiness: Int) {
        print("⌚️ CharacterStats: Loading tamagotchi")
        print("  - ID: \(id.uuidString)")
        print("  - ImageSet: \(imageSetName)")
        
        // 기존 다마고치가 있고, 다른 다마고치로 전환하는 경우
        if let currentId = selectedTamagotchiId, currentId != id {
            print("  - Sending previous tamagotchi stats to iPhone")
            delegate?.characterStatsDidUpdate(id: currentId, energy: self.energy, fullness: self.fullness, happiness: self.happiness)
        }
        
        // 새로운 다마고치 로드
        if selectedTamagotchiId != id {
            print("  - Loading new tamagotchi!")
            
            selectedTamagotchiId = id
            self.imageSetName = imageSetName
            self.energy = energy
            self.fullness = fullness
            self.happiness = happiness
            currentState = .idle
            
            defaults.set(id.uuidString, forKey: AppGroupKeys.selectedId)
            defaults.set(imageSetName, forKey: AppGroupKeys.selectedImageSetName)
        } else if self.imageSetName != imageSetName {
            print("  - ImageSet changed!")
            self.imageSetName = imageSetName
            defaults.set(imageSetName, forKey: AppGroupKeys.selectedImageSetName)
        }
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
        defaults.set(energy, forKey: AppGroupKeys.selectedEnergy)
        defaults.set(fullness, forKey: AppGroupKeys.selectedFullness)
        defaults.set(happiness, forKey: AppGroupKeys.selectedHappiness)
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
