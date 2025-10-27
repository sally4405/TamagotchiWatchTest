//
//  DebugView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/24/25.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var characterStats: CharacterStats
    @EnvironmentObject var inventoryManger: InventoryManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Coin")
                        .font(.headline)
                    
                    HStack {
                        debugButton("-10") {
                            currencyManager.currentCoins -= 10
                        }
                        Text("\(currencyManager.currentCoins)")
                            .frame(width: 50)
                        debugButton("+10") {
                            currencyManager.currentCoins += 10
                        }
                    }
                    
                    debugButton("reset") {
                        currencyManager.resetAll()
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Character Stats")
                        .font(.headline)

                    HStack {
                        debugButton("-10") {
                            characterStats.energy = max(0, characterStats.energy - 10)
                        }
                        Text("\(characterStats.energy)")
                            .font(.caption)
                            .frame(width: 50)
                            .foregroundStyle(Color.cyan)
                        debugButton("+10") {
                            characterStats.energy = min(100, characterStats.energy + 10)
                        }
                    }
                    
                    HStack {
                        debugButton("-10") {
                            characterStats.fullness = max(0, characterStats.fullness - 10)
                        }
                        Text("\(characterStats.fullness)")
                            .font(.caption)
                            .frame(width: 50)
                            .foregroundStyle(Color.pink)
                        debugButton("+10") {
                            characterStats.fullness = min(100, characterStats.fullness + 10)
                        }
                    }
                                        
                    HStack {
                        debugButton("-10") {
                            characterStats.happiness = max(0, characterStats.happiness - 10)
                        }
                        Text("\(characterStats.happiness)")
                            .font(.caption)
                            .frame(width: 50)
                            .foregroundStyle(Color.yellow)
                        debugButton("+10") {
                            characterStats.happiness = min(100, characterStats.happiness + 10)
                        }
                    }
                    
                    debugButton("reset to 0") {
                        characterStats.energy = 0
                        characterStats.fullness = 0
                        characterStats.happiness = 0
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inventory")
                        .font(.headline)
                    debugButton("reset all item") {
                        inventoryManger.items.removeAll()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Debug")
    }
    
    @ViewBuilder
    private func debugButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.caption2)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    NavigationStack {
        DebugView()
            .environmentObject(CurrencyManager())
            .environmentObject(CharacterStats())
            .environmentObject(InventoryManager())
    }
}
