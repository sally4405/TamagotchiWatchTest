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
            }
            .navigationTitle("MENU")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StepCounter())
        .environmentObject(CurrencyManager())
}
