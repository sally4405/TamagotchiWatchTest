//
//  StepCounter.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import Foundation
import HealthKit

@MainActor
class StepCounter: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    @Published var authorizationError: String?
    @Published var todaySteps: Int = 0
        
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
    
    func fetchTodaySteps() async {
        guard isAuthorized, let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now)
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            
            Task { @MainActor in
                self.todaySteps = steps
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Testing Only (Remove in Production)
    #if DEBUG
    func addTestSteps(_ amount: Int) {
        todaySteps += amount
    }
    #endif
}
