//
//  ItemSelectionSheet.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/24/25.
//

import SwiftUI

struct ItemSelectionSheet: View {
    let category: Item.ItemCategory
    let onItemSelected: (Item) -> Void
    
    @EnvironmentObject var inventoryManager: InventoryManager
    @EnvironmentObject var characterStats: CharacterStats
    @Environment(\.dismiss) var dismiss
    
    var ownedItems: [Item] {
        Items.all
            .filter { $0.category == category }
            .filter { inventoryManager.hasItem($0.id) }
    }
    
    var body: some View {
        if ownedItems.isEmpty {
            VStack(spacing: 12) {
                Text("보유 중인 \(category == .food ? "음식" : "장난감")이 없습니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(ownedItems) { item in
                        itemCard(item)
                    }
                }
                .padding(4)
            }
        }
    }
    
    @ViewBuilder
    private func itemCard(_ item: Item) -> some View {
        Button {
            useItem(item)
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(item.imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(2)
                Text("\(inventoryManager.getItemCount(item.id))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 4, y: -4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            Circle()
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private func useItem(_ item: Item) {
        guard inventoryManager.hasItem(item.id) else { return }
        inventoryManager.useItem(item.id)
        characterStats.applyItem(effects: item.effects)
        dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onItemSelected(item)
        }
    }
}

#Preview {
    ItemSelectionSheet(category: .food, onItemSelected: { _ in })
        .environmentObject(InventoryManager())
        .environmentObject(CharacterStats())
}
