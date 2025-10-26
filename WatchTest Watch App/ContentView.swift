//
//  ContentView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    MainView()
                } label: {
                    Label("메인", systemImage: "house.fill")
                }
                
                NavigationLink {
                    ExchangeView()
                } label: {
                    Label("코인 환전", systemImage: "dollarsign.circle.fill")
                }
                
                NavigationLink {
                    ShopView()
                } label: {
                    Label("상점", systemImage: "cart.fill")
                }
                
                NavigationLink {
                    InventoryView()
                } label: {
                    Label("인벤토리", systemImage: "bag.fill")
                }
                
                NavigationLink {
                    DebugView()
                } label: {
                    Label("Debug", systemImage: "ladybug.fill")
                }
            }
            .navigationTitle("MENU")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CharacterStats())
        .environmentObject(StepCounter())
        .environmentObject(CurrencyManager())
        .environmentObject(InventoryManager())
}
