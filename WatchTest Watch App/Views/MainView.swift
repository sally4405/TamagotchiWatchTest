//
//  MainView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import SwiftUI

struct MainView: View {
     var body: some View {
         VStack(alignment: .center, spacing: 12){
             Text("main")
                  .font(.headline)
              
              Text("(캐릭터 화면 예정)")
                  .font(.caption)
                  .foregroundColor(.secondary)
         }
         .navigationTitle("Main")
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}
