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
    var titles: [String] = ["Bas", "Tom", "Sven", "Thomas"]
    var dates: [String] = ["07-04-2014", "Gisteren", "20-01-2015", "18:39"]
    var messages: [String] = ["Wat is dan uw probleem?", "Heeft u geprobeerd het aan en uit te zetten?", "Weet u zeker dat de stekker er in zit?", "Ik ga mijn best voor u doen om dit op te lossen!"]
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
        var nib = UINib(nibName: "ChatCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "cell")
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
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        
        searchBar.layer.borderColor = UIColor.clearColor().CGColor
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
        var cell: ChatCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! ChatCell

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
            cell.title.text = "In de wachtrij..."
		}
		cell.message.text = room!.messages![room!.messages!.count - 1].content
        println(room!.messages![room!.messages!.count - 1])
		cell.date.text = room!.messages![room!.messages!.count - 1].niceDate

        return cell
    }
    

    @IBAction func logOut(sender: UIButton) {
        defaults.removeObjectForKey("userID")
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toChat"){
            var chatc = segue.destinationViewController as! ChatController
            var chatCell = sender as! ChatCell
            chatc.receivedTitle = chatCell.title.text
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
