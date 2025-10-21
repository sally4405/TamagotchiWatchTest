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
    
     var body: some View {
         ScrollView {
             VStack(alignment: .center, spacing: 12){
                 ZStack{
                     Image("room\(roomNumber)")
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
                 
                 HStack(spacing: 10) {
                     Button {
                         roomNumber = 1
                     } label: {
                         Circle()
                             .strokeBorder(lineWidth: 2)
                             .foregroundStyle(Color.white)
                             .frame(width: 40, height: 40)
                     }
                     .buttonStyle(PlainButtonStyle())
                     .background(Color.pink)
                     .cornerRadius(20)
                     
                     Button {
                         roomNumber = 2
                     } label: {
                         Circle()
                             .strokeBorder(lineWidth: 2)
                             .foregroundStyle(Color.white)
                             .frame(width: 40, height: 40)
                     }
                     .buttonStyle(PlainButtonStyle())
                     .background(Color.blue)
                     .cornerRadius(20)
                     
                     Button {
                         roomNumber = 3
                     } label: {
                         Circle()
                             .strokeBorder(lineWidth: 2)
                             .foregroundStyle(Color.white)
                             .frame(width: 40, height: 40)
                     }
                     .buttonStyle(PlainButtonStyle())
                     .background(Color.yellow)
                     .cornerRadius(20)

                     
                     Spacer()
                 }
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
