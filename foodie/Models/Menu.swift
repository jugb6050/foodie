//
//  Menu.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-27.
//

import Foundation

struct Menu: Codable {
    let _id: String
    let description: String
    let name: String
    let restaurant: String
    let food_categories: [FoodCategory]
}
