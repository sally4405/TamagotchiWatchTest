//
//  TamagotchiListView.swift
//  WatchTest
//
//  Created by sello.axz on 11/3/25.
//

import SwiftUI

struct TamagotchiListView: View {
    @EnvironmentObject var manager: TamagotchiManager
    @State private var selectedForPreview: UUID?
    @State private var showAddSheet: Bool = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(manager.tamagotchis) { tamagotchi in
                            TamagotchiCard(
                                tamagotchi: tamagotchi,
                                isSelected: manager.selectedTamagotchiId == tamagotchi.id,
                                isPreviewSelected: selectedForPreview == tamagotchi.id
                            )
                            .onTapGesture {
                                if selectedForPreview == tamagotchi.id {
                                    selectedForPreview = nil
                                } else {
                                    selectedForPreview = tamagotchi.id
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                if let selectedId = selectedForPreview {
                    Button {
                        manager.selectTamagochi(selectedId)
                        selectedForPreview = nil
                    } label: {
                        Text("선택")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("다마고치 목록")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddTamagotchiView()
            }
        }
    }
}

#Preview {
    TamagotchiListView()
        .environmentObject(TamagotchiManager())
}
