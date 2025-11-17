//
//  MainView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import SwiftUI
import SpriteKit

struct MainView: View {
    @EnvironmentObject var tamagotchiManager: TamagotchiManager
    @Environment(\.scenePhase) var scenePhase

    @State private var scene: TamagotchiScene?
    private let characterViewSize: CGFloat = 100
    @State private var roomNumber: Int = 1
    @State private var isPark: Bool = false
    @State private var showFoodSelection: Bool = false
    @State private var showToySelection: Bool = false

    var body: some View {
        ScrollView {
            if tamagotchiManager.currentTamagotchi == nil {
                noTamagotchiView
            } else {
                gameView
            }
        }
        .navigationTitle(tamagotchiManager.currentTamagotchi?.name ?? "메인")
        .environment(\.scenePhase, scenePhase)
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                updateScene()
            }
        }
        .onAppear {
            updateScene()
        }
        .onChange(of: tamagotchiManager.currentTamagotchi?.id) {
            updateScene(forceRecreate: true)
        }
        .onChange(of: tamagotchiManager.currentTamagotchi?.imageSetName) { oldValue, newValue in
            if let imageSetName = newValue {
                updateCharacterImageSet(imageSetName)
            }
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
                        statusBar(icon: "bolt.fill", value: tamagotchiManager.currentTamagotchi?.stats.energy ?? 0, color: .cyan)
                        statusBar(icon: "heart.fill", value: tamagotchiManager.currentTamagotchi?.stats.fullness ?? 0, color: .pink)
                        statusBar(icon: "music.note", value: tamagotchiManager.currentTamagotchi?.stats.happiness ?? 0, color: .yellow)
                    }
                    .padding(4)
                }

                VStack {
                    Spacer()
                    if let scene = scene {
                        SpriteView(scene: scene)
                            .frame(width: characterViewSize, height: characterViewSize)
                            .onTapGesture { location in
                                if tamagotchiManager.currentState == .sleeping {
                                    tamagotchiManager.wakeUp()
                                } else {
                                    scene.handleTap(
                                        at: location,
                                        viewWidth: characterViewSize,
                                        viewHeight: characterViewSize
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
                            tamagotchiManager.startSleeping()
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
        .onChange(of: tamagotchiManager.currentState) { oldValue, newValue in
            if newValue == .sleeping {
                scene?.showSleepIndicator()
            } else {
                scene?.hideSleepIndicator()
            }
        }
        .sheet(isPresented: $showFoodSelection) {
            ItemSelectionSheet(category: .food) { item in
                scene?.showItemEffect(itemImageName: item.imageName)
                tamagotchiManager.applyItem(item.effects)
                showStatChanges(for: item.effects)
            }
        }
        .sheet(isPresented: $showToySelection) {
            ItemSelectionSheet(category: .toy) { item in
                scene?.showItemEffect(itemImageName: item.imageName)
                tamagotchiManager.applyItem(item.effects)
                showStatChanges(for: item.effects)
            }
        }
    }
    
    private func updateScene(forceRecreate: Bool = false) {
        guard let tamagotchi = tamagotchiManager.currentTamagotchi else {
            scene = nil
            return
        }
        
        if scene == nil || forceRecreate {
            scene = TamagotchiScene(imageSetName: tamagotchi.imageSetName)
        }
    }
    
    private func updateCharacterImageSet(_ imageSetName: String) {
        scene?.updateCharacter(imageSetName: imageSetName)
    }

    private func showStatChanges(for effects: ItemEffects) {
        guard let scene = scene else { return }

        if let energy = effects.energy, energy != 0 {
            scene.showStatChange(text: energy > 0 ? "+\(energy)" : "\(energy)", color: .cyan)
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
        .background(color.opacity(tamagotchiManager.currentState == .sleeping ? 0.2 : 0.5))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 1)
        )
        .disabled(tamagotchiManager.currentState == .sleeping)
        .opacity(tamagotchiManager.currentState == .sleeping ? 0.4 : 1.0)
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
            .environmentObject(TamagotchiManager())
    }
}
