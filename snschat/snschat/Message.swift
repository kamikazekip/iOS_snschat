//
//  Message.swift
//  snschat
//
//  Created by Erik Brandsma on 07/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message: NSObject, NSURLConnectionDelegate {
    
    var _id: String?
    var sender: String?
    var content: String?
    var type: String?
    var status: String?
    var oldDate: Int?
    var dateSent: NSDate?
    var niceDate: String!
    
    var lastStatusCode = 1
    var data: NSMutableData! = NSMutableData()
    var lastOperation: String!
    var defaults: NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    var server: String!
    
    init(_id: String?, sender: String?, content: String?, type: String?, status: String?, dateSent: NSDate, oldDate: Int) {
        super.init()
        self._id = _id
        self.sender = sender
        self.content = content
        self.type = type
        self.status = status
        self.dateSent = dateSent
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.niceDate = dateFormatter.stringFromDate(self.dateSent!)
        self.oldDate = oldDate
    }
    
	init(message: JSON) {
        super.init()
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
            self.oldDate = dateSent
            self.dateSent = NSDate(timeIntervalSince1970: NSTimeInterval((dateSent/1000)))
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.niceDate = dateFormatter.stringFromDate(self.dateSent!)
    }
}