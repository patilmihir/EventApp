//
//  User.swift
//  EventBrite
//
//  Created by Mihir Patil on 12/5/17.
//  Copyright © 2017 Mihir Patil. All rights reserved.
//

import Foundation

class User
{
    var email: String
    var password: String
    
    init(email:String,password:String)
    {
        self.email = email
        self.password = password
    }
    
    func getEmail() -> String {
        return self.email
    }
    
    
}
