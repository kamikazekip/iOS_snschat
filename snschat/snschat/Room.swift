//
//  Room.swift
//  snschat
//
//  Created by Gideon Spierings on 25-04-15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import Foundation
import SwiftyJSON

class Room: NSObject {

	// Properties
    var _id: String!
	var checked: Int?
	var customer: User?
	var employee: User?
	var messages: [Message]?
	var status: String?
    var hasEmployee: Bool?
    var unreadMessages: Int = 0
    
	init(jsonRoom room: JSON) {
        super.init()
		self.messages = [Message]()
        
        // Vul id
        if let _id = room["_id"].string {
            self._id = _id
        }
        
		// Vul checked
		if let checked = room["checked"].number as? Int {
			self.checked = checked
		}

		// Vul customer
		if let customer = room["customer"] as JSON? {
			self.customer = User(jsonUser: customer)
		}

		// Vul employee
		if let employee = room["employee"] as JSON? {
			self.employee = User(jsonUser: employee)
		}
        
        if(self.employee?._id != nil){
            self.hasEmployee = true
        } else {
            self.hasEmployee = false
            self.employee?._id = "In de wachtrij"
        }
        
		// Vul messages
		for message: JSON in room["messages"].arrayValue {
            var newMessage = Message(message: message)
            if (newMessage.status == "unread" && newMessage.sender != self.customer!._id) {
                self.unreadMessages = self.unreadMessages + 1
            }
            self.messages?.append(newMessage)
        }
        self.messages!.sort({ $0.dateSent!.timeIntervalSinceNow < $1.dateSent!.timeIntervalSinceNow })
        
		// Vul status
		if let status = room["status"].string {
			self.status = status
		}
    }
}