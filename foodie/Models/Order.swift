//
//  Order.swift
//  foodie
//
//  Created by Raiyan Z. Jugbhery on 2021-04-05.
//

import Foundation

class Order{
private let userName: String
private let userPhone: String
private let userEmail: String
private let restaurantName: String
private let orderTotal: String
private let orderDate: String
private let orderID: Int
private let restaurantNumber: String

    init(userName: String, userPhone: String, userEmail: String, restaurantName: String, orderTotal: String, orderDate: String, orderID: Int, restaurantNumber: String){
        self.userName = userName
        self.userPhone = userPhone
        self.userEmail = userEmail
        self.restaurantName = restaurantName
        self.restaurantNumber = restaurantNumber
        self.orderTotal = orderTotal
        self.orderDate = orderDate
        self.orderID = orderID
    }
    
    func getUserName() -> String {
        return self.userName
    }
    
    func getUserPhone() -> String {
        return self.userPhone
    }
    
    func getUserEmail() -> String {
        return self.userEmail
    }
    
    func getRestaurantName() -> String {
        return self.restaurantName
    }
    
    func getOrderTotal() -> String {
        return self.orderTotal
    }
    
    func getOrderDate() -> String {
        return self.orderDate
    }
    
    func getRestaurantNumber() -> String{
        return self.restaurantNumber
    }
    
    func getOrderID() -> String{
        return String(self.orderID)
    }
    
    
}
