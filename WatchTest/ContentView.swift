//
//  ContentView.swift
//  WatchTest
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tamagotchiManager = TamagotchiManager()
    
    var body: some View {
        TabView {
            TamagotchiListView()
                .tabItem {
                    Label("다마고치", systemImage: "face.smiling")
                }
        }
        .environmentObject(tamagotchiManager)
    }
}

#Preview {
    ContentView()
}
