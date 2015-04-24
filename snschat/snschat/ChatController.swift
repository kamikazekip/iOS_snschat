//
//  ChatController.swift
//  snschat
//
//  Created by Jip Verhoeven on 20/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class ChatController: UIViewController {

    var receivedTitle: String!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleBarTitle: UINavigationItem!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!

	let socket = SocketIOClient(socketURL: "localhost:10040")
    
    var messages: [Message]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBarTitle.title = receivedTitle
        self.textField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        messages = [Message(name: "Erik", date: "10:30", message:"Ik heb hulp nodig"), Message(name: receivedTitle, date: "10:35", message: "Wat is dan uw probleem?"),
            Message(name: "Erik", date: "10:37", message: "Ik kan niet internetbankieren!"), Message(name: receivedTitle, date: "10:40", message: "Waar loopt u precies vast en wat heeft u al geprobeerd? Misschien heeft u uw pincode verkeerd ingevoerd.")];
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0

		/*
		 *	Socket callbacks
		 */

		socket.on("connect") {data, ack in
			println("socket connected")
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
        return self.messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: ChatBubble
        if (self.messages[indexPath.row].name == "Erik") {
            cell = self.tableView.dequeueReusableCellWithIdentifier("chatBubbleRight") as! ChatBubble
        }
        else {
            cell = self.tableView.dequeueReusableCellWithIdentifier("chatBubbleLeft") as! ChatBubble
            cell.name.text = self.messages[indexPath.row].name
        }
        cell.message.text = self.messages[indexPath.row].message
        cell.date.text = self.messages[indexPath.row].date
        return cell
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        if(!textField.text.isEmpty){
            var message = Message(name: "Erik", date: "12:30", message:
                textField.text)
            messages.append(message)
            self.tableView.reloadData()
            self.textField.text = ""
        }
    }
}
