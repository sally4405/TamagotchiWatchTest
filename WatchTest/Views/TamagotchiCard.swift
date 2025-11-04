//
//  TamagotchiCard.swift
//  WatchTest
//
//  Created by sello.axz on 11/3/25.
//

import SwiftUI

struct TamagotchiCard: View {
    let tamagotchi: Tamagotchi
    let isSelected: Bool
    let isPreviewSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(tamagotchi.imageSetName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            
            Text(tamagotchi.name)
                .font(.caption)
                .lineLimit(1)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPreviewSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isPreviewSelected ? 3 : 1)
        )
    }
}

#Preview {
    HStack {
        TamagotchiCard(tamagotchi: Tamagotchi(name: "피카츄", imageSetName: "character1"), isSelected: false, isPreviewSelected: false)
        TamagotchiCard(tamagotchi: Tamagotchi(name: "꼬부기", imageSetName: "character2"), isSelected: true, isPreviewSelected: false)
        TamagotchiCard(tamagotchi: Tamagotchi(name: "파이리", imageSetName: "character1"), isSelected: false, isPreviewSelected: true)
    }
    .padding()
}
