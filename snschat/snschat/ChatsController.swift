//
//  ChatsController.swift
//  snschat
//
//  Created by Erik Brandsma on 13/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: NSIndexPath?
    var defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var chatSearch: UISearchBar!
    
    var overlay: UIView?
    let tapRec: UITapGestureRecognizer = UITapGestureRecognizer()

	var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRec.addTarget(self, action: "tappedOverlay")
        
        self.performSegueWithIdentifier("toLogin", sender: self)
        defaults.setBool(false, forKey: "fromLogin");
        defaults.synchronize()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.tableView.layer.borderWidth = 1
        
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
        self.chatSearch.layer.borderColor = UIColor.whiteColor().CGColor
        self.chatSearch.layer.borderWidth = 1
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
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        
        searchBar.setShowsCancelButton(true, animated: true)
    
        overlay = UIView(frame: view.frame)
        overlay!.backgroundColor = UIColor.blackColor()
        overlay!.alpha = 0.5
        
        overlay!.addGestureRecognizer(tapRec)
        
        self.tableView.addSubview(overlay!)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tappedOverlay()
    }
    
    func tappedOverlay() {
        self.view.endEditing(true)
        chatSearch.setShowsCancelButton(false, animated: true);
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        overlay?.removeFromSuperview()
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
        self.tableView.backgroundView = nil
        return self.user != nil ? self.user!.rooms.count : 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("toChat", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: ChatCell = self.tableView.dequeueReusableCellWithIdentifier("chatCell") as! ChatCell

		// TODO: Lees eerst de TODO in LoginController.
		// TODO: Wat hieronder outcomment staat zal waarschijnlijk wel werken, of
		//		 in ieder geval bijna. Dit moet ook gedaan worden voor de andere
		//		 velden. Raak je in de war dan kan je spieken in functies zoals
		//		 init(jsonRoom room: JSON) van Room (model) en nog wat andere
		//		 modellen. In de numberOfRowsInSection functie (paar regels hierboven)
		//		 staat al een werkende counter.

		let room = self.user?.rooms[indexPath.row]
        
//		Titel is 'on hold' wanneer nog geen employee gekoppeld is.
		if let employee_id = room!.employee!._id {
			cell.title.text = employee_id
		} else {
            cell.title.text = "In de wachtrij"
		}
        cell.room = room!
		cell.message.text = room!.messages![room!.messages!.count - 1].content
        println(room!.messages![room!.messages!.count - 1])
		cell.date.text = room!.messages![room!.messages!.count - 1].niceDate

        return cell
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
