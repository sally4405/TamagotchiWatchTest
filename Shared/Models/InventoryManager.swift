//
//  InventoryManager.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/21/25.
//

import Foundation

@MainActor
class InventoryManager: ObservableObject {
    private let defaults: UserDefaults
    
    @Published var items: [String: Int] = [:] {
        didSet {
            saveData()
        }
    }
    
    init() {
        self.defaults = UserDefaults(suiteName: AppGroup.suiteName) ?? .standard
        loadData()
    }
    
    func addItem(_ itemId: String, count: Int = 1) {
        let currentCount = items[itemId] ?? 0
        items[itemId] = currentCount + count
    }
    
    func useItem(_ itemId: String) {
        guard let currentCount = items[itemId], currentCount > 0 else {
            return
        }
        
        items[itemId] = currentCount - 1
        if items[itemId] == 0 {
            items.removeValue(forKey: itemId)
        }
        return
    }
    
    func getItemCount(_ itemId: String) -> Int {
        return items[itemId] ?? 0
    }
    
    func hasItem(_ itemId: String) -> Bool {
        return getItemCount(itemId) > 0
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: AppGroupKeys.inventoryItems)
        }
        
        #if os(watchOS)
        WatchConnectivityManager.shared.sendInventoryToiPhone(items)
        #endif
    }
    
    private func loadData() {
        if let data = defaults.data(forKey: AppGroupKeys.inventoryItems),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            items = decoded
        }
    }
}
