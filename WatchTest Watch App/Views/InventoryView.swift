//
//  InventoryView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/23/25.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    
    var ownedFoods: [Item] {
        Items.foods.filter { inventoryManager.hasItem($0.id) }
    }
    
    var ownedToys: [Item] {
        Items.toys.filter { inventoryManager.hasItem($0.id) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if ownedFoods.isEmpty && ownedToys.isEmpty {
                    Text("보유 중인 아이템이 없습니다")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    if !ownedFoods.isEmpty {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(ownedFoods) { item in
                                inventoryItemCard(item)
                            }
                        }
                    }
                    
                    if !ownedFoods.isEmpty && !ownedToys.isEmpty {
                        Divider()
                    }
                    
                    if !ownedFoods.isEmpty {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(ownedToys) { item in
                                inventoryItemCard(item)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("인벤토리")
    }
    
    @ViewBuilder
    private func inventoryItemCard(_ item: Item) -> some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                Image(item.imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(2)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Text("\(inventoryManager.getItemCount(item.id))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InventoryView()
            .environmentObject(InventoryManager())
    }
}
