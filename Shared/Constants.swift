//
//  Constants.swift
//  WatchTest
//
//  Created by sello.axz on 11/4/25.
//

import Foundation

enum AppGroupKeys {
    // Tamagotchi List (iOS)
    static let tamagotchiList = "tamagotchi_list"

    // Selected Tamagotchi ID (iOS)
    static let selectedId = "selected_tamagotchi_id"

    // Selected Tamagotchi Object (watchOS)
    static let selectedTamagotchi = "selected_tamagotchi"

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
