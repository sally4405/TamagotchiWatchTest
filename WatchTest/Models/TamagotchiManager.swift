//
//  TamagocthiManager.swift
//  WatchTest
//
//  Created by sello.axz on 11/3/25.
//

import Foundation

@MainActor
class TamagotchiManager: ObservableObject {
    @Published var tamagotchis: [Tamagotchi] = []
    @Published var selectedTamagotchiId: UUID?
    
    private let defaults: UserDefaults
    
    private enum Keys {
        static let tamagotchiList = "tamagotch_list"
        static let selectedId = "selected_tamagotchi_id"
        static let selectedImageSetName = "selected_tamagotchi_imageSetName"
        static let selectedEnergy = "selected_tamagotchi_energy"
        static let selectedFullness = "selected_tamagotchi_fullness"
        static let selectedHappiness = "selected_tamagotchi_happiness"
    }
    
    init() {
        self.defaults = UserDefaults(suiteName: "group.com.sello.WatchTest") ?? .standard
        loadTamagotchis()
        loadSelectedId()
    }
    
    // MARK: - Load
    private func loadTamagotchis() {
        guard let data = defaults.data(forKey: Keys.tamagotchiList) else { return }
        tamagotchis = (try? JSONDecoder().decode([Tamagotchi].self, from: data)) ?? []
    }
    
    private func loadSelectedId() {
        guard let idString = defaults.string(forKey: Keys.selectedId),
              let id = UUID(uuidString: idString) else { return }
        selectedTamagotchiId = id
    }
    
    // MARK: - Save
    private func saveTamagotchis() {
        guard let data = try? JSONEncoder().encode(tamagotchis) else { return }
        defaults.set(data, forKey: Keys.tamagotchiList)
    }

    // MARK: - Public Methods
    func addTamagotchi(name: String, imageSetName: String) {
        let newTamagotchi = Tamagotchi(name: name, imageSetName: imageSetName)
        tamagotchis.append(newTamagotchi)
        saveTamagotchis()
    }
    
    func selectTamagochi(_ id: UUID) {
        if let previousId = selectedTamagotchiId {
            saveStatsFromWatchOS(previousId)
        }
        
        selectedTamagotchiId = id
        
        if let selectedTamagotchi = tamagotchis.first(where: { $0.id == id }) {
            notifyWatchOS(selectedTamagotchi)
        }
    }
    
    func updateStats(id: UUID, energy: Int, fullness: Int, happiness: Int) {
        guard let index = tamagotchis.firstIndex(where: { $0.id == id }) else { return }
        tamagotchis[index].energy = energy
        tamagotchis[index].fullness = fullness
        tamagotchis[index].happiness = happiness
        saveTamagotchis()
    }
    
    // MARK: - Private Methods
    private func saveStatsFromWatchOS(_ id: UUID) {
        let energy = defaults.integer(forKey: Keys.selectedEnergy)
        let fullness = defaults.integer(forKey: Keys.selectedFullness)
        let happiness = defaults.integer(forKey: Keys.selectedHappiness)
        
        updateStats(id: id, energy: energy, fullness: fullness, happiness: happiness)
    }
    
    private func notifyWatchOS(_ tamagotchi: Tamagotchi) {
        defaults.set(tamagotchi.id.uuidString, forKey: Keys.selectedId)
        defaults.set(tamagotchi.imageSetName, forKey: Keys.selectedImageSetName)
        defaults.set(tamagotchi.energy, forKey: Keys.selectedEnergy)
        defaults.set(tamagotchi.fullness, forKey: Keys.selectedFullness)
        defaults.set(tamagotchi.happiness, forKey: Keys.selectedHappiness)
        
        NotificationCenter.default.post(name: .tamagotchiSelectionChanged, object: nil)
    }
}

// MARK: - Notification Names
 extension Notification.Name {
    static let tamagotchiSelectionChanged = Notification.Name("TamagotchiSelectionChanged")
}
