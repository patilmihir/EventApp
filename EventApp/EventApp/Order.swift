//
//  Order.swift
//  EventApp
//
//  Created by Mihir Patil on 12/15/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import Foundation

class Order
{
    var eventId: Int
    var orderId: String
    var quantity: Int32
    var url: String
    
    init(eventId:Int,orderId:String, quantity: Int32, url:String)
    {
        self.eventId = eventId
        self.orderId = orderId
        self.quantity = quantity
        self.url = url
    }
    
}
