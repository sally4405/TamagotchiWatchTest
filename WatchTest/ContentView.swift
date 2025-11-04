//
//  ContentView.swift
//  WatchTest
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TamagotchiListView()
                .tabItem {
                    Label("다마고치", systemImage: "face.smiling")
                }
            
            InventoryView()
                .tabItem {
                    Label("인벤토리", systemImage: "bag")
                }
        }
    }
}

#Preview {
    ContentView()
}
