//
//  ExchangeView.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/16/25.
//

import SwiftUI

struct ExchangeView: View {
    @EnvironmentObject var stepCounter: StepCounter
    @EnvironmentObject var currencyManager: CurrencyManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if stepCounter.isAuthorized {
                    let availableSteps = stepCounter.todaySteps - currencyManager.lastProcessedSteps
                    let canExchange = availableSteps >= 100
                    
                    VStack(spacing: 4) {
                        Text("환전 가능 걸음 수")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(max(0, availableSteps))")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if canExchange {
                            Text("→ \(availableSteps / 100) 코인으로 환전 가능")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Divider()
                    
                    VStack(spacing: 4) {
                        Text("보유 코인")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(currencyManager.currentCoins)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.yellow)
                    }
                    
                    Button {
                        currencyManager.processSteps(stepCounter.todaySteps)
                    } label: {
                        Text("환전하기")
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canExchange)
                    
                    // MARK: - Testing Only
                    #if DEBUG
                    Divider()
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Button("+10 걸음") {
                                stepCounter.addTestSteps(10)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption2)
                            
                            Button("+100 걸음") {
                                stepCounter.addTestSteps(100)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption2)
                        }
                        
                        Button("reset") {
                            currencyManager.resetAll()
                            stepCounter.todaySteps = 0
                        }
                        .buttonStyle(.bordered)
                        .font(.caption2)
                        .foregroundStyle(.red)
                    }
                    .padding(.top, 8)
                    #endif
                    
                } else {
                    VStack {
                        Text("HeathKit 권한 필요")
                            .font(.caption)
                        
                        Button("권한 요청") {
                            Task {
                                await stepCounter.requestAuthorization()
                            }
                        }
                    }
                }
                
                if let error = stepCounter.authorizationError {
                    Text("error: \(error)")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("코인 환전")
        .task {
            if stepCounter.isAuthorized {
                await stepCounter.fetchTodaySteps()
            }
        }
        .refreshable {
            if stepCounter.isAuthorized {
                await stepCounter.fetchTodaySteps()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExchangeView()
            .environmentObject(StepCounter())
            .environmentObject(CurrencyManager())
    }
}
