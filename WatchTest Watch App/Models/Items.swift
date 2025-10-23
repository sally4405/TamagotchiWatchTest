//
//  Items.swift
//  WatchTest Watch App
//
//  Created by sello.axz on 10/21/25.
//

import Foundation

struct Items {
    // MARK: - Food Items
    static let food1 = Item(
        id: "food1",
        imageName: "food1",
        price: 1,
        category: .food,
        effects: ItemEffects(energy: nil, fullness: 20, happiness: 5)
    )
    
    static let food2 = Item(
        id: "food2",
        imageName: "food2",
        price: 2,
        category: .food,
        effects: ItemEffects(energy: nil, fullness: 30, happiness: 10)
    )

    static let candy1 = Item(
        id: "candy1",
        imageName: "candy1",
        price: 2,
        category: .food,
        effects: ItemEffects(energy: 5, fullness: 10, happiness: 15)
    )

    static let candy2 = Item(
        id: "candy2",
        imageName: "candy2",
        price: 3,
        category: .food,
        effects: ItemEffects(energy: 10, fullness: 15, happiness: 20)
    )

    // MARK: - Toy Items
    static let ball1 = Item(
        id: "ball1",
        imageName: "ball1",
        price: 5,
        category: .toy,
        effects: ItemEffects(energy: -10, fullness: nil, happiness: 30)
    )

    static let gift1 = Item(
        id: "gift1",
        imageName: "gift1",
        price: 1,
        category: .toy,
        effects: ItemEffects(energy: -5, fullness: nil, happiness: 40)
    )

    static let gift2 = Item(
        id: "gift2",
        imageName: "gift2",
        price: 2,
        category: .toy,
        effects: ItemEffects(energy: -5, fullness: nil, happiness: 50)
    )
    
    // MARK: - All Items
    static let all: [Item] = [food1, food2, candy1, candy2, ball1, gift1, gift2]
    
    static let foods: [Item] = all.filter { $0.category == .food }
    static let toys: [Item] = all.filter { $0.category == .toy }
    
    static func item(id: String) -> Item? {
        return all.first { $0.id == id }
    }
}
