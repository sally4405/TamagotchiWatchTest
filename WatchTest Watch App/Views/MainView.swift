//
//  MainView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import SwiftUI
import SpriteKit

struct MainView: View {
    @EnvironmentObject var characterStats: CharacterStats
    
    @State private var scene = TamagotchiScene()
    private let charaterViewSize: CGFloat = 100
    @State private var roomNumber: Int = 1
    @State private var isPark: Bool = false
    @State private var showFoodSelection: Bool = false
    @State private var showToySelection: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                ZStack(alignment: .top) {
                    Image("\(isPark ? "park1" : "room\(roomNumber)")")
                        .resizable()
                        .scaledToFit()
                        .blur(radius: 1)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 72, height: 42)
                            .blur(radius: 2)
                        VStack(spacing: 2) {
                            statusBar(icon: "bolt.fill", value: characterStats.energy, color: .cyan)
                            statusBar(icon: "heart.fill", value: characterStats.fullness, color: .pink)
                            statusBar(icon: "music.note", value: characterStats.happiness, color: .yellow)
                        }
                        .padding(4)
                    }
                    
                    VStack {
                        Spacer()
                        SpriteView(scene: scene)
                            .frame(width: charaterViewSize, height: charaterViewSize)
                            .onTapGesture { location in
                                if characterStats.currentState == .sleeping {
                                    characterStats.wakeUp()
                                } else {
                                    scene.handleTap(
                                        at: location,
                                        viewWidth: charaterViewSize,
                                        viewHeight: charaterViewSize
                                    )
                                }
                            }
                    }
                    
                    HStack() {
                        Spacer()
                        VStack(spacing: 4) {
                            Spacer()
                            actionButton(icon: "bed.double.fill", color: .cyan) {
                                characterStats.startSleeping()
                            }
                            actionButton(icon: "fork.knife", color: .pink) {
                                showFoodSelection = true
                            }
                            actionButton(icon: "gamecontroller.fill", color: .yellow) {
                                showToySelection = true
                            }
                        }
                        .padding(4)
                        
                    }
                }
                
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { number in
                        backgroundButton(color: roomColor(for: number)) {
                            isPark = false
                            roomNumber = number
                        }
                    }
                    Spacer()
                    backgroundButton(color: .green) {
                        isPark = true
                    }
                }
            }
        }
        .navigationTitle("메인")
        .onChange(of: characterStats.currentState) { oldValue, newValue in
            if newValue == .sleeping {
                scene.showSleepIndicator()
            } else {
                scene.hideSleepIndicator()
            }
        }
        .sheet(isPresented: $showFoodSelection) {
            ItemSelectionSheet(category: .food) { item in
                scene.showItemEffect(itemImageName: item.imageName)
            }
        }
        .sheet(isPresented: $showToySelection) {
            ItemSelectionSheet(category: .toy) { item in
                scene.showItemEffect(itemImageName: item.imageName)
            }
        }
    }
    
    @ViewBuilder
    private func statusBar(icon: String, value: Int, color: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundStyle(color)
                .frame(width: 10)
            
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(color, lineWidth: 1)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value) / 100)
                    //                        .animation(.linear(duration: 0.2))
                }
            }
            .frame(width: 50, height: 8)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .foregroundStyle(Color.white)
                .frame(width: 25, height: 25)
                .padding(2)
        }
        .buttonStyle(PlainButtonStyle())
        .background(color.opacity(characterStats.currentState == .sleeping ? 0.2 : 0.5))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 1)
        )
        .disabled(characterStats.currentState == .sleeping)
        .opacity(characterStats.currentState == .sleeping ? 0.4 : 1.0)
    }
    
    @ViewBuilder
    private func backgroundButton(color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Circle()
                .strokeBorder(lineWidth: 2)
                .foregroundStyle(Color.white)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(PlainButtonStyle())
        .background(color)
        .cornerRadius(15)
    }
    
    private func roomColor(for number: Int) -> Color {
        switch number {
        case 1: return .pink
        case 2: return .blue
        case 3: return .yellow
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
            .environmentObject(CharacterStats())
    }
}
