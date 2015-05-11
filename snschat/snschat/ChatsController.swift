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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.backgroundColor = UIColor.clearColor()
            controller.searchBar.barTintColor = UIColor.whiteColor()
            //controller.searchBar.layer.borderColor = UIColor.lightGrayColor().CGColor
            controller.searchBar.clipsToBounds = true
            controller.searchBar.layer.borderWidth = 0.5
            controller.searchBar.placeholder = "Zoeken"
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        self.performSegueWithIdentifier("toLogin", sender: self)
        defaults.setBool(false, forKey: "fromLogin");
        defaults.synchronize()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.tableView.layer.borderWidth = 0.5
        
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if(selectedIndex != nil){
            tableView.deselectRowAtIndexPath(selectedIndex!, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(defaults.boolForKey("fromLogin") == true){
            var type = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            var setting = UIUserNotificationSettings(forTypes: type, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            UIApplication.sharedApplication().registerForRemoteNotifications()
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
                    return self.filteredRooms.count
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
        var cell: ChatCell = self.tableView.dequeueReusableCellWithIdentifier("chatCell") as! ChatCell
        let room: Room!
        if(self.resultSearchController.active){
            room = self.filteredRooms[indexPath.row]
        } else {
            room = self.user?.rooms[indexPath.row]
        }
    
        cell.title.text = room!.employee?._id
        cell.room = room!
		cell.message.text = room!.messages![room!.messages!.count - 1].content
		cell.date.text = room!.messages![room!.messages!.count - 1].niceDate

        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if(searchController.searchBar.text == ""){
            self.filteredRooms = self.user!.rooms
        } else {
            self.filteredRooms.removeAll(keepCapacity: false)
            let searchPredicate = NSPredicate(format: "self.employee._id contains[c] %@", searchController.searchBar.text)
            let array = (self.user!.rooms as NSArray).filteredArrayUsingPredicate(searchPredicate)
            self.filteredRooms = array as! [Room]
        }
        self.tableView.reloadData()
    }

    @IBAction func logOut(sender: UIButton) {
        defaults.removeObjectForKey("userID")
        self.user = nil
        self.tableView.reloadData()
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toChat"){
            var chatc = segue.destinationViewController as! ChatController
            var chatCell = sender as! ChatCell
            chatc.room = chatCell.room
            chatc.hidesBottomBarWhenPushed = true;
        } else if(segue.identifier == "toLogin"){
            var loginNavController: UINavigationController = segue.destinationViewController as! UINavigationController
            var loginController: LoginController = loginNavController.viewControllers.first as! LoginController
            loginController.chatsController = self
        }
    }

	func setCurrentUser(user: User) {
		self.user = user
	}
}
