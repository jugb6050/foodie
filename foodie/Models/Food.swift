//
//  Food.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-27.
//

import Foundation

struct Food: Codable {
    let _id: String
    let name: String
    let description: String
    let price: Double
    let category: String
    let images: [APIImage]
}
