//
//  TamagotchiManager.swift
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
    
    init() {
        self.defaults = UserDefaults(suiteName: AppGroup.suiteName) ?? .standard
        loadTamagotchis()
        loadSelectedId()
    }
    
    // MARK: - Load
    private func loadTamagotchis() {
        guard let data = defaults.data(forKey: AppGroupKeys.tamagotchiList) else { return }
        tamagotchis = (try? JSONDecoder().decode([Tamagotchi].self, from: data)) ?? []
    }
    
    private func loadSelectedId() {
        guard let idString = defaults.string(forKey: AppGroupKeys.selectedId),
              let id = UUID(uuidString: idString) else { return }
        selectedTamagotchiId = id
    }
    
    // MARK: - Save
    private func saveTamagotchis() {
        guard let data = try? JSONEncoder().encode(tamagotchis) else { return }
        defaults.set(data, forKey: AppGroupKeys.tamagotchiList)
    }

    // MARK: - Public Methods
    func addTamagotchi(name: String, imageSetName: String) {
        let newTamagotchi = Tamagotchi(name: name, imageSetName: imageSetName)
        tamagotchis.append(newTamagotchi)
        saveTamagotchis()
    }
    
    func updateTamagotchi(id: UUID, name: String?, imageSetName: String?) {
        guard let index = tamagotchis.firstIndex(where: { $0.id == id }) else { return }
        
        if let name = name {
            tamagotchis[index].name = name
        }
        
        if let imageSetName = imageSetName {
            tamagotchis[index].imageSetName = imageSetName
        }
        
        saveTamagotchis()
        
        if selectedTamagotchiId == id {
            WatchConnectivityManager.shared.sendTamagotchiToWatch(tamagotchis[index])
        }
    }
    
    func deleteTamagotchi(id: UUID) {
        if selectedTamagotchiId == id {
            selectedTamagotchiId = nil
            defaults.removeObject(forKey: AppGroupKeys.selectedId)
            
            WatchConnectivityManager.shared.sendTamagotchiToWatch()
        }
        
        tamagotchis.removeAll(where: { $0.id == id })
        saveTamagotchis()
    }
    
    func selectTamagotchi(_ id: UUID) {
        selectedTamagotchiId = id
        defaults.set(id.uuidString, forKey: AppGroupKeys.selectedId)
        
        if let selectedTamagotchi = tamagotchis.first(where: { $0.id == id }) {
            WatchConnectivityManager.shared.sendTamagotchiToWatch(selectedTamagotchi)
        }
    }
    
    func updateStats(id: UUID, stats: TamagotchiStats) {
        guard let index = tamagotchis.firstIndex(where: { $0.id == id }) else { return }
        tamagotchis[index].stats = stats
        saveTamagotchis()
    }
}
