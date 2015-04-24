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
            println("HALLO")
            var type = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            var setting = UIUserNotificationSettings(forTypes: type, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            UIApplication.sharedApplication().registerForRemoteNotifications()
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
        return self.titles.count
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
        cell.title.text = titles[indexPath.row]
        cell.message.text = messages[indexPath.row]
        cell.date.text = dates[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toChat"){
            var chatc = segue.destinationViewController as! ChatController
            var chatCell = sender as! ChatCell
            chatc.receivedTitle = chatCell.title.text
            chatc.hidesBottomBarWhenPushed = true;
        }
    }
}
