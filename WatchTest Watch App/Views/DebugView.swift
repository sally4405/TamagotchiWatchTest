//
//  DebugView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/24/25.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var tamagotchiManager: TamagotchiManager
    @EnvironmentObject var inventoryManager: InventoryManager

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
                            if var tamagotchi = tamagotchiManager.currentTamagotchi {
                                tamagotchi.stats.energy = max(0, tamagotchi.stats.energy - 10)
                                tamagotchiManager.currentTamagotchi = tamagotchi
                            }
                        }
                        Text("\(tamagotchiManager.currentTamagotchi?.stats.energy ?? 0)")
                            .font(.caption)
                            .frame(width: 50)
                            .foregroundStyle(Color.cyan)
                        debugButton("+10") {
                            if var tamagotchi = tamagotchiManager.currentTamagotchi {
                                tamagotchi.stats.energy = min(100, tamagotchi.stats.energy + 10)
                                tamagotchiManager.currentTamagotchi = tamagotchi
                            }
                        }
                    }

                    HStack {
                        debugButton("-10") {
                            if var tamagotchi = tamagotchiManager.currentTamagotchi {
                                tamagotchi.stats.fullness = max(0, tamagotchi.stats.fullness - 10)
                                tamagotchiManager.currentTamagotchi = tamagotchi
                            }
                        }
                        Text("\(tamagotchiManager.currentTamagotchi?.stats.fullness ?? 0)")
                            .font(.caption)
                            .frame(width: 50)
                            .foregroundStyle(Color.pink)
                        debugButton("+10") {
                            if var tamagotchi = tamagotchiManager.currentTamagotchi {
                                tamagotchi.stats.fullness = min(100, tamagotchi.stats.fullness + 10)
                                tamagotchiManager.currentTamagotchi = tamagotchi
                            }
                        }
                    }

                    HStack {
                        debugButton("-10") {
                            if var tamagotchi = tamagotchiManager.currentTamagotchi {
                                tamagotchi.stats.happiness = max(0, tamagotchi.stats.happiness - 10)
                                tamagotchiManager.currentTamagotchi = tamagotchi
                            }
                        }
                        Text("\(tamagotchiManager.currentTamagotchi?.stats.happiness ?? 0)")
                            .font(.caption)
                            .frame(width: 50)
                            .foregroundStyle(Color.yellow)
                        debugButton("+10") {
                            if var tamagotchi = tamagotchiManager.currentTamagotchi {
                                tamagotchi.stats.happiness = min(100, tamagotchi.stats.happiness + 10)
                                tamagotchiManager.currentTamagotchi = tamagotchi
                            }
                        }
                    }

                    debugButton("reset to 0") {
                        if var tamagotchi = tamagotchiManager.currentTamagotchi {
                            tamagotchi.stats.energy = 0
                            tamagotchi.stats.fullness = 0
                            tamagotchi.stats.happiness = 0
                            tamagotchiManager.currentTamagotchi = tamagotchi
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Inventory")
                        .font(.headline)
                    debugButton("reset all item") {
                        inventoryManager.items.removeAll()
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
            .environmentObject(TamagotchiManager())
            .environmentObject(InventoryManager())
    }
}
