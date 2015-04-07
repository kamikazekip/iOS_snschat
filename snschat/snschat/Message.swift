//
//  Message.swift
//  snschat
//
//  Created by Erik Brandsma on 07/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import Foundation

class Message {
    
    var name: String?
    var date: String?
    var message: String?
    
    init(name: String, date: String, message: String) {
        self.name = name
        self.date = date
        self.message = message
    }
    
}