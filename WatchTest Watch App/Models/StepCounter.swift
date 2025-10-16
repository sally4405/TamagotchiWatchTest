//
//  StepCounter.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import Foundation
import HealthKit

class StepCounter: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    @Published var authorizationError: String?
    
    func isHealthDataAvailable() -> Bool {
        // TODO: HKHealthStore.isHealthDataAvailable() 반환
    }
    
    func requestAuthorization() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            authorizationError = "Step Type not available."
            return
        }
        
        let typesToRead: Set<HKObjectType> = [stepType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            await MainActor.run {
                self.isAuthorized = true
                self.authorizationError = nil
            }
        } catch {
            await MainActor.run {
                self.isAuthorized = false
                self.authorizationError = error.localizedDescription
            }
        }
    }
}
