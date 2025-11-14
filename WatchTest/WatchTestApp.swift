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
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tamagotchiManager)
                .environmentObject(watchConnectivity)
                .onAppear {
                    WatchConnectivityManager.shared.tamagotchiManager = tamagotchiManager
                }
        }
    }
}
