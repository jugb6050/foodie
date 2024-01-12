//
//  PastOrders.swift
//  foodie
//
//  Created by Raiyan Z. Jugbhery on 2021-04-05.
//

import Foundation

class PastOrders {
    public static var sharedInstance = [Order]()
    
    
    init(){
    
    }
    
    static func isEmpty()-> Bool {
        return PastOrders.sharedInstance.count == 0
    }
    
    static func getCount() -> Int {
        return PastOrders.sharedInstance.count
    }
    
    static func addOrder(newOrder: Order){
        PastOrders.sharedInstance.append(newOrder)
    }
    
    static func clearPastOrders() {
        PastOrders.sharedInstance = [Order]()
    }
    
}
