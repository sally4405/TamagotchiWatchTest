//
//  Item.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/21/25.
//

import Foundation

struct Item: Identifiable, Codable {
    let id: String
    let imageName: String
    let price: Int
    let category: ItemCategory
    let effects: ItemEffects
    
    enum ItemCategory: String, Codable {
        case food
        case toy
    }
}
