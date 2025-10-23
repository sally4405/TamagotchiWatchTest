//
//  CurrencyManager.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import Foundation

@MainActor
class CurrencyManager: ObservableObject {
    private let defaults: UserDefaults
    
    @Published var currentCoins: Int = 0
    @Published var lastProcessedSteps: Int = 0
    @Published var lastProcessedDate: Date? = nil
    
    private let stepsPerCoin: Int = 100 // 100걸음 = 1코인
    
    private enum Keys {
        static let coins = "userCoins"
        static let lastSteps = "lastProcessedSteps"
        static let lastDate = "lastProcessedDate"
    }
    
    init() {
        self.defaults = UserDefaults(suiteName: "group.com.sello.watchtest") ?? .standard
        loadData()
    }
    
    private func loadData() {
        currentCoins = defaults.integer(forKey: Keys.coins)
        lastProcessedSteps = defaults.integer(forKey: Keys.lastSteps)
        lastProcessedDate = defaults.object(forKey: Keys.lastDate) as? Date
    }
    
    private func saveData() {
        defaults.set(currentCoins, forKey: Keys.coins)
        defaults.set(lastProcessedSteps, forKey: Keys.lastSteps)
        defaults.set(lastProcessedDate, forKey: Keys.lastDate)
    }
    
    func processSteps(_ currentSteps: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = lastProcessedDate.map { Calendar.current.startOfDay(for: $0) }
        
        let newSteps: Int
        
        if lastDate != today {
            newSteps = currentSteps
            lastProcessedSteps = 0
        } else {
            newSteps = max(0, currentSteps - lastProcessedSteps)
        }
        
        let earnedCoins = newSteps / stepsPerCoin
        let processedSteps = earnedCoins * stepsPerCoin
        
        currentCoins += earnedCoins
        lastProcessedSteps += processedSteps
        lastProcessedDate = Date()
        saveData()
    }
    
    func spendCoins(_ amount: Int) {
        guard currentCoins >= amount else { return }
        currentCoins -= amount
        saveData()
    }
    
    func resetAll() {
        currentCoins = 0
        lastProcessedSteps = 0
        lastProcessedDate = nil
        saveData()
    }
}
