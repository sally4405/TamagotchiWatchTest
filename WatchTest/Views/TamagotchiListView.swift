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
    @State private var editingTamagotchi: Tamagotchi?
    @State private var deletingTamagotchi: Tamagotchi?
    
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
                    HStack(spacing: 8) {
                        Button {
                            manager.selectTamagotchi(selectedId)
                            selectedForPreview = nil
                        } label: {
                            Text("선택")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            editingTamagotchi = manager.tamagotchis.first(where: { $0.id == selectedId })
                        } label: {
                            Image(systemName: "pencil")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            deletingTamagotchi = manager.tamagotchis.first(where: { $0.id == selectedId })
                        } label: {
                            Image(systemName: "trash")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
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
            .sheet(item: $editingTamagotchi) { tamagotchi in
                EditTamagotchiView(tamagotchi: tamagotchi)
            }
            .alert("다마고치 삭제", isPresented: .constant(deletingTamagotchi != nil), presenting: deletingTamagotchi) { tamagotchi in
                Button("취소", role: .cancel) {
                    deletingTamagotchi = nil
                    selectedForPreview = nil
                }
                Button("삭제", role: .destructive) {
                    manager.deleteTamagotchi(id: tamagotchi.id)
                    deletingTamagotchi = nil
                    selectedForPreview = nil
                }
            } message: { tamagotchi in
                Text("\(tamagotchi.name)을(를) 삭제하시겠습니까?")
            }
        }
    }
}

#Preview {
    TamagotchiListView()
        .environmentObject(TamagotchiManager())
}
