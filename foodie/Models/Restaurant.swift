//
//  Restaurant.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-27.
//

import Foundation

struct Restaurant: Codable {
    let _id: String
    let name: String
    let phone: String
    let email: String
    let location: Location
    let menus: [Menu]
    let logo: APIImage
}
