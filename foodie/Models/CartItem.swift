//
//  CartItem.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-29.
//

import Foundation
import UIKit

class CartItem {
    private let item: Food
    private let image: UIImage
    private var quantity: Int
    private let restaurant_id: String
    
    init(item: Food, image: UIImage, quantity: Int, restaurant_id: String) {
        self.item = item
        self.image = image
        self.quantity = quantity
        self.restaurant_id = restaurant_id
    }
    
    func getImage() -> UIImage {
        return self.image
    }
    
    func getItem() -> Food {
        return self.item
    }
    
    func getQuantity() -> Int {
        return self.quantity
    }
    
    func getFoodID() -> String {
        return self.item._id
    }

    func getRestaurantID() -> String {
        return self.restaurant_id
    }
    
    func setQuantity(quantity: Int) {
        self.quantity = quantity
    }
    
}
