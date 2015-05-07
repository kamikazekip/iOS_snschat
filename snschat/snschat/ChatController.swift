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
        self.tableView.estimatedRowHeight = 59.6
        
        self.server = defaults.valueForKey("server") as! String
        
        self.socket = SocketIOClient(socketURL: "\(self.server)")
		socket.on("connect") {data, ack in
			println("socket connected")
            self.socket.emit("join", self.room._id)
            
            self.socket.on("message") { message, ack in
                println(message)
                var swiftMessage = message as! [AnyObject]
                let swiftDictionary = swiftMessage[0] as! [String: AnyObject]
                
                let _id = swiftDictionary["_id"]! as! String
                let sender = swiftDictionary["sender"] as! String
                let content = swiftDictionary["content"] as! String
                let type = swiftDictionary["type"]! as! String
                let status = swiftDictionary["status"] as! String
                let timeInterval = NSTimeInterval((swiftDictionary["dateSent"] as! Int / 1000))
                let dateSent = NSDate(timeIntervalSince1970: timeInterval)
                
                var newMessage = Message(_id: _id, sender: sender, content: content, type: type, status: status, dateSent: dateSent)
                
                self.room!.messages!.append(newMessage)
                self.scrollToBottom()
            }
		}
		socket.connect()
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollToBottom()
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController() == true){
            self.socket.disconnect(fast: true);
            self.socket.emit("disconnect", self.room._id)
        }
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
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return UITableViewAutomaticDimension
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
            
            var data = ["content": textField.text, "sender": user, "room_id": self.room._id]
            
            self.socket.emit("message", data)
            
            textField.text = ""
        }
    }
    
    func scrollToBottom(){
        self.tableView.reloadData()
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            var iPath = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0)-1,
                inSection: self.tableView.numberOfSections()-1)
            self.tableView.scrollToRowAtIndexPath(iPath,
                atScrollPosition: UITableViewScrollPosition.Bottom,
                animated: true)
        });
    }
}
