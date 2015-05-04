//
//  ChatController.swift
//  snschat
//
//  Created by Jip Verhoeven on 20/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import SwiftyJSON

class ChatController: UIViewController {

    var receivedTitle: String!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleBarTitle: UINavigationItem!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!

    let defaults = NSUserDefaults.standardUserDefaults()
    
    var server: String!
    var socket: SocketIOClient!
    
    var room: Room!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
        
        self.tableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.tableView.layer.borderWidth = 1
        
        self.server = defaults.valueForKey("server") as! String
        
		/*
		 *	Socket callbacks
		 */
        
        self.socket = SocketIOClient(socketURL: "\(self.server)")
		socket.on("connect") {data, ack in
			println("socket connected")
            self.socket.emit("join", self.room._id)
            
            self.socket.on("message") { message, ack in
                println(message)
            }
		}

		socket.connect()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                self.view.frame.origin.y = 0 - keyboardHeight
            }
        }
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y  = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.room.messages!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: ChatBubble
        if (self.room.messages![indexPath.row].sender == defaults.stringForKey("userID")) {
            cell = self.tableView.dequeueReusableCellWithIdentifier("chatBubbleRight") as! ChatBubble
        }
        else {
            cell = self.tableView.dequeueReusableCellWithIdentifier("chatBubbleLeft") as! ChatBubble
            cell.name.text = self.room.messages![indexPath.row].sender
        }
        cell.message.text = self.room.messages![indexPath.row].content
        cell.date.text = self.room.messages![indexPath.row].niceDate
        return cell
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        if(!textField.text.isEmpty) {
            var user: String! = defaults.stringForKey("userID")
            
            var data = ["content": textField.text, "sender": user]
            
            var message: String! = "{\'content\': \'\(textField.text)\', \'sender\': \'\(user)\'}"
            
            self.socket.emit("message", data)
            
            textField.text = ""
        }
    }
}
