//
//  WatchTestApp.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI

@main
struct WatchTest_Watch_AppApp: App {
    @StateObject private var characterStats = CharacterStats()
    @StateObject private var stepCounter = StepCounter()
    @StateObject private var currencyManager = CurrencyManager()
    @StateObject private var inventoryManager = InventoryManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(characterStats)
                .environmentObject(stepCounter)
                .environmentObject(currencyManager)
                .environmentObject(inventoryManager)
        }
    }
}
