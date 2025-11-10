//
//  AddTamagotchiView.swift
//  WatchTest
//
//  Created by sello.axz on 11/3/25.
//

import SwiftUI

struct AddTamagotchiView: View {
    @EnvironmentObject var manager: TamagotchiManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedImageSet = "Character1"
    
    let availableImageSets: [String] = ["Character1", "Character2"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("이름") {
                    TextField("다마고치 이름", text: $name)
                }
                
                Section("이미지") {
                    Picker("이미지 선택", selection: $selectedImageSet) {
                        ForEach(availableImageSets, id: \.self) { imageSet in
                            HStack {
                                Image(imageSet)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 40)
                                Text(imageSet)
                            }
                            .tag(imageSet)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("새 다마고치")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        manager.addTamagotchi(name: name, imageSetName: selectedImageSet)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTamagotchiView()
        .environmentObject(TamagotchiManager())
}
