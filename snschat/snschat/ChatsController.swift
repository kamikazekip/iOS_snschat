//
//  ChatsController.swift
//  snschat
//
//  Created by Erik Brandsma on 13/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: NSIndexPath?
    var defaults = NSUserDefaults.standardUserDefaults()

	var user: User?
    var filteredRooms = [Room]()
    var resultSearchController = UISearchController()
    var overlay: UIView?
    let tapRec: UITapGestureRecognizer = UITapGestureRecognizer()
    var overlayDissapearing: Bool!
    var overlayAppearing: Bool!
    var server: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        server = defaults.stringForKey("server")
        overlayDissapearing = false
        overlayAppearing = false
        tapRec.addTarget(self, action: "tappedOverlay")
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.backgroundColor = UIColor.whiteColor()
            controller.searchBar.barTintColor = UIColor.whiteColor()
            controller.searchBar.tintColor = UIColor(red: 103/255, green: 58/255, blue: 183/255, alpha: 1)
            controller.searchBar.placeholder = "Zoeken"
            controller.searchBar.delegate = self
            self.navigationController?.navigationBar.layer.borderColor = UIColor.clearColor().CGColor
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        self.performSegueWithIdentifier("toLogin", sender: self)
        defaults.setBool(false, forKey: "fromLogin");
        defaults.synchronize()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if(selectedIndex != nil){
            tableView.deselectRowAtIndexPath(selectedIndex!, animated: true)
        }
    }
    
   
    
    override func viewDidAppear(animated: Bool) {
        if(defaults.boolForKey("fromLogin")){
            var type = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            var setting = UIUserNotificationSettings(forTypes: type, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            defaults.setBool(false, forKey: "fromLogin")
        }
        if (self.user != nil) {
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var label = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        
        if (self.user != nil && self.user!.rooms.count == 0) {
            label.text = "U heeft nog geen chats."
            label.textAlignment = NSTextAlignment.Center
            label.numberOfLines = 0
            self.tableView.backgroundView = label
            return 0
        }
        else {
            self.tableView.backgroundView = nil
            if (self.user != nil) {
                if( self.resultSearchController.active){
                    if (self.filteredRooms.count == 0) {
                        label.text = "Geen resultaten gevonden."
                        label.textAlignment = NSTextAlignment.Center
                        label.numberOfLines = 0
                        self.tableView.backgroundView = label
                        return 0
                    } else {
                        self.tableView.backgroundView = nil
                        return self.filteredRooms.count
                    }
                } else {
                    return self.user!.rooms.count
                }
            } else {
                return  0
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.resultSearchController.active = false
        self.performSegueWithIdentifier("toChat", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : ChatCell
        
        let room: Room!
        if(self.resultSearchController.active){
            room = self.filteredRooms[indexPath.row]
        } else {
            room = self.user?.rooms[indexPath.row]
        }
        if(room!.unreadMessages > 0){
            cell = self.tableView.dequeueReusableCellWithIdentifier("chatCellUnread") as! ChatCell
            cell.unreadMessages.text = String(room!.unreadMessages)
        } else {
            cell = self.tableView.dequeueReusableCellWithIdentifier("chatCell") as! ChatCell
        }
        
        // Toont avatar
        var newUrl = "\(self.server)/public/img/profile/\(room!.employee!._id!).jpg".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if let url = NSURL(string: newUrl) {
            if let data = NSData(contentsOfURL: url){
                if let imageFromUrl = UIImage(data: data) {
                    cell.avatar.image = imageFromUrl
                }
            }
        }
        
        cell.title.text = room!.employee?._id
        cell.tableView = self.tableView
        cell.room = room!
        if(room!.messages!.count != 0){
            cell.message.text = room!.messages![room!.messages!.count - 1].content
            cell.date.text = room!.messages![room!.messages!.count - 1].niceDate
        }
        cell.room.socketDelegate.chatCell = cell
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if(self.resultSearchController.active == true){
            if(self.resultSearchController.searchBar.text != ""){
                self.overlayOff()
                self.filteredRooms.removeAll(keepCapacity: false)
                let searchPredicate = NSPredicate(format: "self.employee._id contains[c] %@", searchController.searchBar.text)
                let array = (self.user!.rooms as NSArray).filteredArrayUsingPredicate(searchPredicate)
                self.filteredRooms = array as! [Room]
            } else {
                self.filteredRooms = self.user!.rooms
                self.overlayOn()
            }
        } else {
            self.overlayOff()
            self.filteredRooms.removeAll(keepCapacity: false)
            let searchPredicate = NSPredicate(format: "self.employee._id contains[c] %@", searchController.searchBar.text)
            let array = (self.user!.rooms as NSArray).filteredArrayUsingPredicate(searchPredicate)
            self.filteredRooms = array as! [Room]
        }
        self.tableView.reloadData()
    }
    
    func tappedOverlay(){
        self.resultSearchController.active = false
    }
    
    func overlayOn(){
        if(self.overlay == nil){
            overlay = UIView(frame: view.frame)
            overlay!.alpha = 0.0
            overlay!.frame.origin.x += 1
            overlay!.frame.origin.y += 10
            overlay!.backgroundColor = UIColor.blackColor()
            overlay!.addGestureRecognizer(tapRec)
            self.tableView.addSubview(overlay!)
        }
        if(self.overlay != nil){
            self.overlayAppearing = true
            self.overlayDissapearing = false
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                self.overlay!.alpha = 0.4
                }, completion: { ( finished: Bool) -> Void in
                    self.overlayAppearing = false
            })
        }
    }
    
    func overlayOff(){
        if(self.overlay != nil){
            if(self.overlayDissapearing == false){
                self.overlayDissapearing = true
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.overlay!.alpha = 0.0
                    }, completion: { ( finished: Bool) -> Void in
                        if(self.overlayAppearing != true){
                            self.overlay?.removeFromSuperview()
                            self.overlay = nil
                            self.overlayDissapearing = false
                        }
                })
            }
        }
    }

    @IBAction func logOut(sender: UIButton) {
        var confirmAlert = UIAlertController(title: "Uitloggen", message: "Weet u zeker dat u wilt uitloggen?", preferredStyle: UIAlertControllerStyle.Alert)
        confirmAlert.addAction(UIAlertAction(title: "Ja", style: .Default, handler: { (action: UIAlertAction!) in
            self.defaults.removeObjectForKey("userID")
            for room: Room in self.user!.rooms {
                room.disconnectSocket()
            }
            self.user = nil
            self.tableView.reloadData()
            self.performSegueWithIdentifier("toLogin", sender: self)
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "Nee", style: .Default, handler: { (action: UIAlertAction!) in
            //Cancel logout
        }))
        self.presentViewController(confirmAlert, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toChat"){
            var chatc = segue.destinationViewController as! ChatController
            var chatCell = sender as! ChatCell
            chatCell.room!.setRead()
            self.tableView.reloadData()
            chatc.room = chatCell.room
            chatc.room!.socketDelegate.chatController = chatc
            chatc.room!.socketDelegate.switchToController()
            chatc.hidesBottomBarWhenPushed = true;
        } else if(segue.identifier == "toLogin"){
            var loginNavController: UINavigationController = segue.destinationViewController as! UINavigationController
            var loginController: LoginController = loginNavController.viewControllers.first as! LoginController
            loginController.chatsController = self
        } else if(segue.identifier == "toCreateChat") {
            var createChatController: CreateChatController = segue.destinationViewController as! CreateChatController
            createChatController.user = self.user!
            createChatController.hidesBottomBarWhenPushed = true;
        }
    }

	func setCurrentUser(user: User) {
		self.user = user
	}
}
