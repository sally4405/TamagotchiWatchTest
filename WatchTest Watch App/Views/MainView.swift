//
//  MainView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import SwiftUI
import SpriteKit

struct MainView: View {
    @State private var scene = TamagotchiScene()
    private let charaterViewSize: CGFloat = 150
    @State private var roomNumber: Int = 1
    @State private var isPark: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12){
                ZStack{
                    Image("\(isPark ? "park1" : "room\(roomNumber)")")
                        .resizable()
                        .frame(width: charaterViewSize, height: charaterViewSize)
                        .blur(radius: 1)
                    SpriteView(scene: scene)
                        .frame(width: charaterViewSize, height: charaterViewSize)
                        .onTapGesture { location in
                            scene.handleTap(
                                at: location,
                                viewWidth: charaterViewSize,
                                viewHeight: charaterViewSize
                            )
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
        .navigationTitle("Main")
    }
    
    private func roomColor(for number: Int) -> Color {
        switch number {
        case 1: return .pink
        case 2: return .blue
        case 3: return .yellow
        default: return .gray
        }
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
}

#Preview {
    NavigationStack {
        MainView()
    }
}
