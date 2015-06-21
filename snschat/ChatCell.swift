//
//  ChatCell.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import AudioToolbox

class ChatCell: UITableViewCell {


    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var unreadMessages: UILabel!
    var server: String!
    var tableView: UITableView!
    var socket: SocketIOClient!
    var socketsInitialised = false
    
    var room: Room!
    
    var receivedMessage: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.borderWidth = 0.8
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.lightGrayColor().CGColor
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        
        message.numberOfLines = 0
        message.sizeToFit()
        if(unreadMessages != nil){
            unreadMessages.clipsToBounds = true
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
        
    func receiveMessage(message: [AnyObject]){
        let swiftDictionary = message[0] as! [String: AnyObject]
        
        let _id = swiftDictionary["_id"]! as! String
        let sender = swiftDictionary["sender"] as! String
        let content = swiftDictionary["content"] as! String
        let type = swiftDictionary["type"]! as! String
        let status = swiftDictionary["status"] as! String
        let oldDate = swiftDictionary["dateSent"] as! NSNumber
        let timeInterval = NSTimeInterval((swiftDictionary["dateSent"] as! Int / 1000))
        let dateSent = NSDate(timeIntervalSince1970: timeInterval)
        
        var newMessage = Message(_id: _id, sender: sender, content: content, type: type, status: status, dateSent: dateSent, oldDate: oldDate)
        self.room!.messages!.append(newMessage)
        self.message.font = UIFont.systemFontOfSize(14.0)
        self.room!.unreadMessages += 1
        
        self.receivedMessage = true
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        self.tableView.reloadData()
    }
    
    func receiveIsTypingEvent(){
        self.receivedMessage = false
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.message!.alpha = 0.0
            }, completion: { ( finished: Bool) -> Void in
                if (!self.receivedMessage) {
                    self.message.text = "Aan het typen..."
                    self.message.font = UIFont.italicSystemFontOfSize(14.0)
                }
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.message!.alpha = 1.0
                    }, completion: { ( finished: Bool) -> Void in
                        
                })
        })
    }
    
    func receiveStoppedTypingEvent(){
        self.receivedMessage = true
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.message!.alpha = 0.0
            }, completion: { ( finished: Bool) -> Void in
                self.message.font = UIFont.systemFontOfSize(14.0)
                self.message.text = self.room!.messages![self.room!.messages!.count - 1].content
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.message!.alpha = 1.0
                    }, completion: { ( finished: Bool) -> Void in
                        
                })
        })
    }
}
