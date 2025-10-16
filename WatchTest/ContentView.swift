//
//  ContentView.swift
//  WatchTest
//
//  Created by sello.axz on 9/12/25.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    let location = CLLocation(latitude: 37.33182, longitude: -121.88633)
    
    @State private var temperature: String = "loading ..."
    @State private var errorMessage: String?
    
    private let weatherService = WeatherService.shared

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
            
            Text("일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사오육칠팔구십")
                .lineLimit(1)
                .truncationMode(.tail)
            Text("일이삼사오육칠팔구십일이삼사오육칠팔구십일이삼사 오육칠팔구십")
                .lineLimit(1)
                .truncationMode(.tail)
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
