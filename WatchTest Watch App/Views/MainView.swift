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
    @Environment(\.scenePhase) var scenePhase
    
    @State private var scene: TamagotchiScene?
    private let charaterViewSize: CGFloat = 100
    @State private var roomNumber: Int = 1
    @State private var isPark: Bool = false
    @State private var showFoodSelection: Bool = false
    @State private var showToySelection: Bool = false
    
    var body: some View {
        ScrollView {
            if characterStats.selectedTamagotchiId == nil {
                noTamagotchiView
            } else {
                gameView
            }
        }
        .navigationTitle("메인")
        .environment(\.scenePhase, scenePhase)
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
//                characterStats.reloadFromUserDefaults()
            }
        }
        .onAppear {
            if characterStats.selectedTamagotchiId != nil {
                scene = TamagotchiScene(imageSetName: characterStats.imageSetName)
            }
        }
        .onChange(of: characterStats.selectedTamagotchiId) { oldValue, newValue in
            if newValue != nil {
                scene = TamagotchiScene(imageSetName: characterStats.imageSetName)
            } else {
                scene = nil
            }
        }
        .onChange(of: characterStats.imageSetName) { oldValue, newValue in
            scene?.updateCharacter(imageSetName: newValue)
        }
    }
    
    private var noTamagotchiView: some View {
        VStack(spacing: 20) {
            Image(systemName: "iphone")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("다마고치를 생성하세요")
                .font(.headline)
            
            Text("iPhone 앱에서 다마고치를\n먼저 생성해주세요!")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button {
//                characterStats.reloadFromUserDefaults()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("새로고침")
                }
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var gameView: some View {
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
                    if let scene = scene {
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
        .onChange(of: characterStats.currentState) { oldValue, newValue in
            if newValue == .sleeping {
                scene?.showSleepIndicator()
            } else {
                scene?.hideSleepIndicator()
            }
        }
        .sheet(isPresented: $showFoodSelection) {
            ItemSelectionSheet(category: .food) { item in
                scene?.showItemEffect(itemImageName: item.imageName)
                showStatChanges(for: item.effects)
            }
        }
        .sheet(isPresented: $showToySelection) {
            ItemSelectionSheet(category: .toy) { item in
                scene?.showItemEffect(itemImageName: item.imageName)
                showStatChanges(for: item.effects)
            }
        }
    }
    
    private func showStatChanges(for effects: ItemEffects) {
        guard let scene = scene else { return }
        
        if let energe = effects.energy, energe != 0 {
            scene.showStatChange(text: energe > 0 ? "+\(energe)" : "\(energe)", color: .cyan)
        }
        if let fullness = effects.fullness, fullness != 0 {
            scene.showStatChange(text: fullness > 0 ? "+\(fullness)" : "\(fullness)", color: UIColor(.pink))
        }
        if let happiness = effects.happiness, happiness != 0 {
            scene.showStatChange(text: happiness > 0 ? "+\(happiness)" : "\(happiness)", color: .yellow)
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
