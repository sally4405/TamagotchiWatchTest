//
//  Constants.swift
//  WatchTest
//
//  Created by sello.axz on 11/4/25.
//

import Foundation

enum AppGroupKeys {
    // Tamagotchi List
    static let tamagotchiList = "tamagotchi_list"
    
    // Selected Tamagotchi
    static let selectedId = "selected_tamagotchi_id"
    static let selectedImageSetName = "selected_tamagotchi_imageSetName"
    static let selectedEnergy = "selected_tamagotchi_energy"
    static let selectedFullness = "selected_tamagotchi_fullness"
    static let selectedHappiness = "selected_tamagotchi_happiness"

    // Inventory
    static let inventoryItems = "inventory_items"
    
    // Currency
    static let coins = "user_coins"
    static let lastSteps = "last_processed_steps"
    static let lastDate = "last_processed_date"
}

enum AppGroup {
    static let suiteName = "group.com.sello.WatchTest"
}
