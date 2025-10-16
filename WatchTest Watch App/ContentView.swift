//
//  ContentView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI
import WeatherKit
import CoreLocation
import HealthKit

struct ContentView: View {
    private let weatherService = WeatherService.shared
    @StateObject private var stepCounter = StepCounter()

    let location = CLLocation(latitude: 37.33182, longitude: -121.88633)
    
    @State private var temperature: String = "loading ..."
    @State private var errorMessage: String?
    

    var body: some View {
        VStack {
            Text("현재 날씨")
                .font(.largeTitle)
                .bold()
            
            if let errorMessage = errorMessage {
                Text("오류 발생")
                    .font(.headline)
                    .foregroundStyle(.red)
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text(temperature)
                    .font(.system(size: 50, weight: .bold))
            }
            
        }
        .padding()
        .task { 
            await fetchWeather()
        }
    }
    
    private func fetchWeather() async {
        do {
            let currentWeather = try await weatherService.weather(for: location)
            
            let currentTemperature = currentWeather.currentWeather.temperature
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .temperatureWithoutUnit
            formatter.numberFormatter.maximumFractionDigits = 0
            
            await MainActor.run {
                self.temperature = formatter.string(from: currentTemperature) + "C"
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.temperature = "---"
                self.errorMessage = error.localizedDescription
                print("WeatherKit Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
