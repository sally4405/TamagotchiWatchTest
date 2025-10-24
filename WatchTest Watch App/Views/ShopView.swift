//
//  ShopView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/23/25.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var inventoryManager: InventoryManager
        
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Image("coin")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("\(currencyManager.currentCoins)")
                        .font(.caption)
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Items.foods) { item in
                            shopItemCard(item)
                    }
                }
                
                Divider()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Items.toys) { item in
                            shopItemCard(item)
                    }
                }
            }
        }
        .navigationTitle("상점")
    }
    
    @ViewBuilder
    private func shopItemCard(_ item: Item) -> some View {
        VStack(spacing: 2) {
            Button {
                currencyManager.spendCoins(item.price)
                inventoryManager.addItem(item.id)
            } label: {
                Image(item.imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(2)
            }
            .buttonStyle(PlainButtonStyle())
            .overlay(
                Circle()
                    .stroke(Color.gray, lineWidth: 1)
            )
            .disabled(currencyManager.currentCoins < item.price)
            .opacity(currencyManager.currentCoins < item.price ? 0.5 : 1)
            
            HStack(spacing: 2) {
                Image("coin")
                    .resizable()
                    .frame(width: 12, height: 12)
                Text("\(item.price)")
                    .font(.caption2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShopView()
            .environmentObject(CurrencyManager())
            .environmentObject(InventoryManager())
    }
}
