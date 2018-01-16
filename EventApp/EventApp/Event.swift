//
//  Event.swift
//  EventBrite
//
//  Created by Mihir Patil on 12/5/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import Foundation

class Event
{
    var id: Int
    var name: String
    var description: String
    var location: String
    var path: String
    var ticketCount : Int32
    var ticketPrice: Int32
    var datetime: Date
    
    
    init(id:Int,name:String,description:String,location:String, path:String,ticketCount:Int32,ticketPrice:Int32, datetime: Date)
    {
        self.id = id
        self.name = name
        self.description = description
        self.location = location
        self.path = path
        self.ticketCount = ticketCount
        self.ticketPrice = ticketPrice
        self.datetime = datetime
    }
    
    
}
