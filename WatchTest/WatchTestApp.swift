//
//  WatchTestApp.swift
//  WatchTest
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI

@main
struct WatchTestApp: App {
    @StateObject private var tamagotchiManager = TamagotchiManager()
    @StateObject private var inventoryManager = InventoryManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tamagotchiManager)
                .environmentObject(inventoryManager)
        }
    }
}
