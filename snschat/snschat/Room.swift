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

	init(jsonRoom room: JSON) {

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

		// Vul messages
		for message: JSON in room["messages"].arrayValue {
			self.messages?.append(Message(message: message))
        }
        self.messages!.sort({ $0.dateSent!.timeIntervalSinceNow < $1.dateSent!.timeIntervalSinceNow })
        
		// Vul status
		if let status = room["status"].string {
			self.status = status
		}
	}
}