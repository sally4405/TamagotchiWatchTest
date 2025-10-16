//
//  ContentView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var stepCounter = StepCounter()

    var body: some View {
        VStack {
            Text("🐽")
        }
        .padding()
    }

}

#Preview {
    ContentView()
}
