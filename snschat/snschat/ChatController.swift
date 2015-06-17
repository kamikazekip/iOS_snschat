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

class ChatController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var receivedTitle: String!
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleBarTitle: UINavigationItem!
    @IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!

    let defaults = NSUserDefaults.standardUserDefaults()
    
    var server: String!
    
    var room: Room!
	var customerTyping: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

		// Functie registreren op het DidChange event (voor 'is typing')
		textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)

        self.textField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        self.tableView.estimatedRowHeight = 59.6
        
        self.server = defaults.valueForKey("server") as! String
        
        self.title = room!.employee!._id
        self.toolBar.layer.borderWidth = 0.5
        self.toolBar.layer.borderColor = UIColor.grayColor().CGColor

    
    }
    
    override func viewDidAppear(animated: Bool) {
        if(self.room.messages!.count != 0){
            scrollToBottom()
        }
        self.navigationController?.navigationItem.title = self.room!.employee?._id
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParentViewController() == true){
            self.room!.socketDelegate.switchToChatCell()
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
        if(self.customerTyping){
            return self.room.messages!.count + 1
        } else {
            return self.room.messages!.count
        }
        
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(indexPath.row == self.room.messages!.count){

			var isTyping: IsTypingCell

            isTyping = self.tableView.dequeueReusableCellWithIdentifier("isTypingCell") as! IsTypingCell
            isTyping.isTypingLabel.text = "Aan het typen..."

			return isTyping
		} else {

			var cell: ChatBubble

			// Checken of het een message of een attachment is
			if (self.room.messages![indexPath.row].type == "message") {

				// Links of rechts?
				if (self.room.messages![indexPath.row].sender == defaults.stringForKey("userID")) {
					cell = self.tableView.dequeueReusableCellWithIdentifier("chatBubbleRight") as! ChatBubble
				}
				else {
					cell = self.tableView.dequeueReusableCellWithIdentifier("chatBubbleLeft") as! ChatBubble
				}

				cell.message.text = self.room.messages![indexPath.row].content
				cell.date.text = self.room.messages![indexPath.row].niceDate

				return cell

			} else {

				var imageCell: ImageBubble

				// Links of rechts?
				if (self.room.messages![indexPath.row].sender == defaults.stringForKey("userID")) {
					imageCell = self.tableView.dequeueReusableCellWithIdentifier("imageBubbleRight") as! ImageBubble
				}
				else {
					imageCell = self.tableView.dequeueReusableCellWithIdentifier("imageBubbleLeft") as! ImageBubble
				}

				imageCell.date.text = self.room.messages![indexPath.row].niceDate

				// Resize opties
				imageCell.imageView!.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
				imageCell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit

				// Download de image
				if let url = NSURL(string: "\(self.server)/\(self.room.messages![indexPath.row].content!)") {
					if let data = NSData(contentsOfURL: url){
						if let imageFromUrl = UIImage(data: data) {
							imageCell.imageView!.image = imageFromUrl
						}
					}
				}

				return imageCell
			}
		}
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        if(!textField.text.isEmpty) {
            var user: String! = defaults.stringForKey("userID")
            println("Verstuur: \(textField.text)")
            var data = ["content": textField.text, "sender": user, "room_id": self.room._id]
            
            self.room.sendMessage(data)
            
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

	func textFieldDidChange(textField: UITextField) {

		if (!self.customerTyping && count(textField.text) > 0) {
			self.customerTyping = true
            self.room.sendIsTypingEvent()
			//self.socket.emit("startTyping", room.customer!._id!)
		}

		if (self.customerTyping && count(textField.text) == 0) {
			self.customerTyping = false
			self.room.sendStoppedTypingEvent()
            //self.socket.emit("stopTyping", room.customer!._id!)
		}
	}
    
    func receiveMessage(message: [AnyObject]){
        let swiftDictionary = message[0] as! [String: AnyObject]
        
        let _id = swiftDictionary["_id"]! as! String
        let sender = swiftDictionary["sender"] as! String
        let content = swiftDictionary["content"] as! String
        let type = swiftDictionary["type"]! as! String
        let status = "read"
        let oldDate = swiftDictionary["dateSent"] as! Int
        let timeInterval = NSTimeInterval((swiftDictionary["dateSent"] as! Int / 1000))
        let dateSent = NSDate(timeIntervalSince1970: timeInterval)
        
        var newMessage = Message(_id: _id, sender: sender, content: content, type: type, status: status, dateSent: dateSent, oldDate: oldDate)
        self.customerTyping = false
        self.room!.messages!.append(newMessage)
        self.room!.changeUnread([newMessage])
        self.scrollToBottom()
    }
    
    func receiveIsTypingEvent(){
        self.customerTyping = true
        self.scrollToBottom()
    }
    
    func receiveStoppedTypingEvent(){
        self.customerTyping = false
        self.scrollToBottom()
    }

	@IBAction func cameraButtonClicked(sender: UIBarButtonItem) {

		let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

		// Maak foto
		let photoAction = UIAlertAction(title: "Maak foto", style: .Default, handler: {(alert: UIAlertAction!) -> Void in
			var imageController = UIImagePickerController()
			imageController.delegate = self
			imageController.sourceType = .Camera
			imageController.allowsEditing = true
			self.presentViewController(imageController, animated: true, completion: nil)
		})

		// Laat fotobibliotheek zien
		let libraryAction = UIAlertAction(title: "Fotobibliotheek", style: .Default, handler: {(alert: UIAlertAction!) -> Void in
			var imageController = UIImagePickerController()
			imageController.delegate = self
			imageController.sourceType = .PhotoLibrary
			imageController.allowsEditing = true
			self.presentViewController(imageController, animated: true, completion: nil)
		})

		// Annuleer
		let cancelAction = UIAlertAction(title: "Annuleer", style: .Cancel, handler: {(alert: UIAlertAction!) -> Void in
			// Shh!
		})

		optionMenu.addAction(photoAction)
		optionMenu.addAction(libraryAction)
		optionMenu.addAction(cancelAction)

		self.presentViewController(optionMenu, animated: true, completion: nil)
	}

	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

		// Verstuur die shit
		// Check dit: https://gist.github.com/janporu-san/e832cdee51974fc55660

		self.dismissViewControllerAnimated(false, completion: nil)
	}
}
