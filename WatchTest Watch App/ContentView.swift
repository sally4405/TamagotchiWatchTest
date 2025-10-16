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
            Text("HealthKit 테스트")
                .font(.headline)
            
            if stepCounter.isAuthorized {
                Text("권한 승인~")
                    .foregroundStyle(.green)
            } else {
                Button("걸음수 권한 요청") {
                    Task {
                        await stepCounter.requestAuthorization()
                    }
                }
            }
            
            if let error = stepCounter.authorizationError {
                Text("error: \(error)")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

}

#Preview {
    ContentView()
}
