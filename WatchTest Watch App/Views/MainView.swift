//
//  MainView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import SwiftUI
import SpriteKit

struct MainView: View {
    @State private var scene: TamagotchiScene = {
        TamagotchiScene(size: CGSize(width: 150, height: 150))
    }()
    
     var body: some View {
         ScrollView {
             VStack(alignment: .center, spacing: 12){
                 SpriteView(scene: scene)
                     .frame(width: 150, height: 150)
                     .onTapGesture { location in
                         let sceneLocation = CGPoint(
                            x: location.x * scene.size.width / 150,
                            y: (150 - location.y) * scene.size.height / 150
                         )
                         scene.handleTap(at: sceneLocation)
                     }
                  
                  Text("(캐릭터 화면 예정)")
                      .font(.caption)
                      .foregroundColor(.secondary)
             }
         }
         .navigationTitle("Main")
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}
