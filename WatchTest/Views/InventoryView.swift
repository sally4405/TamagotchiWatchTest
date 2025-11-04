//
//  InventoryView.swift
//  WatchTest
//
//  Created by sello.axz on 11/3/25.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var inventoryManager: InventoryManager
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Items.all) { item in
                    let count = inventoryManager.getItemCount(item.id)
                    if count > 0 {
                        InventoryItemRow(item: item, count: count)
                    }
                }
            }
            .navigationTitle("인벤토리")
        }
    }
}

struct InventoryItemRow: View {
    let item: Item
    let count: Int
    
    var body: some View {
        HStack(spacing: 24) {
            ZStack(alignment: .topTrailing) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .offset(x: 4, y: -4)
                    
            }
            
            effectsText
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var effectsText: some View {
        HStack(spacing: 16) {
            if let energy = item.effects.energy {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                    Text("\(energy > 0 ? "+" : "")\(energy)")
                }
                .foregroundStyle(.cyan)
            }
            
            if let fullness = item.effects.fullness {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                    Text("\(fullness > 0 ? "+" : "")\(fullness)")
                }
                .foregroundStyle(.pink)
            }
            
            if let happiness = item.effects.happiness {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                    Text("\(happiness > 0 ? "+" : "")\(happiness)")
                }
                .foregroundStyle(.yellow)
            }
        }
        .font(.headline)
    }
}

#Preview {
    InventoryView()
        .environmentObject({
            let manager = InventoryManager()
            manager.addItem("food1", count: 1)
            manager.addItem("ball1", count: 1)
            return manager
        }())
}
