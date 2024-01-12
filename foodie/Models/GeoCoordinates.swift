//
//  GeoCoordinates.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-28.
//

import Foundation

struct GeoCoordinates: Codable {
    let coordinates: [Double]
    
    subscript(index: Int) -> Double {
        let coordinate = coordinates[index]
        
        return coordinate
    }
}
