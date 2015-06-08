//
//  Room.swift
//  snschat
//
//  Created by Gideon Spierings on 25-04-15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import Foundation
import SwiftyJSON
import Socket_IO_Client_Swift

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
    
    var lastOperation: String!
    var lastStatusCode = 1
    var data: NSMutableData! = NSMutableData()
    var defaults: NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    var server: String!
    var socket: SocketIOClient!
    
    var socketDelegate: SocketDelegate!
    
	init(jsonRoom room: JSON) {
        super.init()
		self.messages = [Message]()
        server = defaults.valueForKey("server") as! String
        
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

        if(self._id != nil){
            self.socketDelegate = SocketDelegate()
            self.initiateSockets()
            self.startSocket()
        }
    }
    
    func setRead(){
        var updatedMessages: [Message] = [Message]()
        self.unreadMessages = 0
        for message: Message in self.messages! {
            if(message.status! != "read" && message.sender != self.customer!._id){
                message.status = "read"
                updatedMessages.append(message)
            }
        }
        if(updatedMessages.count > 0){
            changeUnread(updatedMessages)
        }
    }
    
    func changeUnread(updatedMessages: [Message]){
        // create the request
        let url = NSURL(string: "\(server)/api/messages")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        var postString = "["
        for (var x = 0; x < updatedMessages.count; x++){
            var message: Message = updatedMessages[x]
            var jsonString = "{ \"_id\": \"\(message._id!)\", \"content\": \"\(message.content!)\", \"dateSent\": \(message.oldDate!), \"sender\": \"\(message.sender!)\", \"status\": \"\(message.status!)\", \"type\": \"\(message.type!)\"}"
            if(x != updatedMessages.count - 1){
                postString = "\(postString) \(jsonString),"
            } else {
                postString = "\(postString) \(jsonString)"
            }
        }
        postString = "\(postString)]"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        lastOperation = "changeUnread"
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            println("Kan niet connecten naar het internet, ")
        }
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Failed with error:\(error.localizedDescription)")
    }
    
    //NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSHTTPURLResponse!) {
        //New request so we need to clear the data object
        self.lastStatusCode = response.statusCode;
        self.data = NSMutableData()
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        if(self.lastStatusCode == 200){
            switch(lastOperation){
            case "changeUnread":
                afterChangeUnread()
            default:
                println("Default case called in lastOperation switch")
            }
        } else {
            println("Er is iets misgegaan op de server, probeer het later nog eens!")
            println(lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func afterChangeUnread(){
        
    }
    
    func initiateSockets(){
        self.socket = SocketIOClient(socketURL: "\(self.server)")
        socket.on("connect") {data, ack in
            self.socket.emit("join", self._id)
            println("\(self.employee!._id) connected")
            
            self.socket.on("message") { message, ack in
                var swiftMessage = message as! [AnyObject]
                self.socketDelegate.receiveMessage(swiftMessage)
            }
            
            self.socket.on("startTyping") { userId, ack in
                let username = (userId as! [String])[0]
                
                if (username == self.employee!._id!) {
                    self.socketDelegate.receiveIsTyping()
                }
            }
            
            self.socket.on("stopTyping") { userId, ack in
                let username = (userId as! [String])[0]
                
                if (username == self.employee!._id!) {
                    self.socketDelegate.receiveStoppedTyping()
                }
            }
        }
    }
    
    func startSocket(){
        socket.connect()
    }
    
    func disconnectSocket(){
        socket.disconnect(fast: true)
    }
    
    func sendMessage(message: [String: String!]){
        self.socket.emit("message", message)
    }
    
    func sendIsTypingEvent(){
        self.socket.emit("startTyping", self.customer!._id!)
    }
    
    func sendStoppedTypingEvent(){
        self.socket.emit("stopTyping", self.customer!._id!)
    }
}