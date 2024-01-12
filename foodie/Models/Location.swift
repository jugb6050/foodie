//
//  Location.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-27.
//

import Foundation

struct Location: Codable {
    let _id: String
    let city: String
    let address: String
    let postal_code: String
    let restaurant: String
    let geo: GeoCoordinates // long, lat
}
