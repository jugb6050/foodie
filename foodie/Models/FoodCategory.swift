//
//  FoodCategory.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-27.
//

import Foundation

struct FoodCategory: Codable {
    let _id: String
    let menu: String
    let name: String
    let foods: [Food]
}
