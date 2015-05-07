//
//  Message.swift
//  snschat
//
//  Created by Erik Brandsma on 07/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message {
    
    var _id: String?
    var sender: String?
    var content: String?
    var type: String?
    var status: String?
    var dateSent: NSDate?
    var niceDate: String!
    
    init(_id: String?, sender: String?, content: String?, type: String?, status: String?, dateSent: NSDate) {
        self._id = _id
        self.sender = sender
        self.content = content
        self.type = type
        self.status = status
        self.dateSent = dateSent
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.niceDate = dateFormatter.stringFromDate(self.dateSent!)
    }
    
	init(message: JSON) {
        fillProps(message)
    }
    
    func fillProps(message: JSON){
        if let _id = message["_id"].string {
            self._id = _id
        }
        if let sender = message["sender"].string {
            self.sender = sender
        }
        if let content = message["content"].string {
            self.content = content
        }
        if let type = message["type"].string {
            self.type = type
        }
        if let status = message["status"].string {
            self.status = status
        }
        if let dateSent = message["dateSent"].int {
            self.dateSent = NSDate(timeIntervalSince1970: NSTimeInterval((dateSent / 1000)))
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.niceDate = dateFormatter.stringFromDate(self.dateSent!)
    }
}