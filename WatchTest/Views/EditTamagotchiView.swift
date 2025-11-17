//
//  EditTamagotchiView.swift
//  WatchTest
//
//  Created by sello.axz on 11/14/25.
//

import SwiftUI

struct EditTamagotchiView: View {
    let tamagotchi: Tamagotchi
    @EnvironmentObject var manager: TamagotchiManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var selectedImageSet: String
    
    let availableImageSets: [String] = ["Character1", "Character2"]
    
    init(tamagotchi: Tamagotchi) {
        self.tamagotchi = tamagotchi
        _name = State(initialValue: tamagotchi.name)
        _selectedImageSet = State(initialValue: tamagotchi.imageSetName)
    }
    
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
            .navigationTitle("다마고치 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        manager.updateTamagotchi(
                            id: tamagotchi.id,
                            name: name,
                            imageSetName: selectedImageSet
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditTamagotchiView(tamagotchi: Tamagotchi(name: "test", imageSetName: "Character1"))
        .environmentObject(TamagotchiManager())
}
