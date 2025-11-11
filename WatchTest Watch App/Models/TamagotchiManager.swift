//
//  TamagotchiManager.swift
//  WatchTest Watch App
//
//  Created by sello.axz
//

import Foundation

enum TamagotchiState: String, Codable {
    case idle
    case sleeping
}

@MainActor
class TamagotchiManager: ObservableObject {
    @Published var currentTamagotchi: Tamagotchi?
    @Published var currentState: TamagotchiState = .idle

    private let defaults: UserDefaults
    private var stateTimer: Timer?

    init() {
        self.defaults = UserDefaults(suiteName: AppGroup.suiteName) ?? .standard
        loadFromUserDefaults()
    }

    // MARK: - Load/Save (UserDefaults - watchOS 내부 영속성)
    private func loadFromUserDefaults() {
        guard let data = defaults.data(forKey: AppGroupKeys.selectedTamagotchi),
              let tamagotchi = try? JSONDecoder().decode(Tamagotchi.self, from: data) else {
            currentTamagotchi = nil
            return
        }

        currentTamagotchi = tamagotchi
        currentState = .idle
    }

    private func saveToUserDefaults() {
        guard let tamagotchi = currentTamagotchi,
              let encoded = try? JSONEncoder().encode(tamagotchi) else { return }
        defaults.set(encoded, forKey: AppGroupKeys.selectedTamagotchi)
    }

    // MARK: - WatchConnectivity
    func loadTamagotchi(_ newTamagotchi: Tamagotchi) {
        print("⌚️ TamagotchiManager: Loading tamagotchi")
        print("  - ID: \(newTamagotchi.id.uuidString)")
        print("  - ImageSet: \(newTamagotchi.imageSetName)")

        // 기존 다마고치가 있고 다른 ID면 iOS로 스텟 전송
        if let current = currentTamagotchi, current.id != newTamagotchi.id {
            print("  - Sending previous stats to iPhone")
            WatchConnectivityManager.shared.sendStatsToiPhone(id: current.id, stats: current.stats)
        }

        // 새 다마고치 로드
        currentTamagotchi = newTamagotchi
        currentState = .idle
        saveToUserDefaults()
    }

    // MARK: - Actions
    func applyItem(_ effects: ItemEffects) {
        guard var tamagotchi = currentTamagotchi else { return }
        tamagotchi.stats.apply(effects)
        currentTamagotchi = tamagotchi
        saveToUserDefaults()
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

    // MARK: - Timer (수면 시스템)
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
        guard var tamagotchi = currentTamagotchi, currentState == .sleeping else { return }

        let sleepEffects = ItemEffects(energy: 1, fullness: -1)
        tamagotchi.stats.apply(sleepEffects)

        if tamagotchi.stats.energy >= TamagotchiStats.limits.upperBound ||
           tamagotchi.stats.fullness <= TamagotchiStats.limits.lowerBound {
            wakeUp()
        }

        currentTamagotchi = tamagotchi
        saveToUserDefaults()
    }
}
