//
//  ChatsController.swift
//  snschat
//
//  Created by Erik Brandsma on 13/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var titles: [String] = ["Jip", "Erik", "Sven", "Gideon"]
    var dates: [String] = ["Today", "Yesterday", "20-01-2015", "Tommorrow"]
    var messages: [String] = ["Bericht 1 van Jip :) die heeeeeeeeeeel erg lang is, waarom weet ik ook niet, maar hij is in ieder geval heel erg lang", "Bericht 2 van Erik :)", "Bericht 3 van Sven :)", "Bericht 4 van Gideon :)"]
    
    @IBOutlet weak var chatSearch: UISearchBar!
    
    var overlay: UIView?
    let tapRec: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapRec.addTarget(self, action: "tappedOverlay")
        
        self.performSegueWithIdentifier("toLogin", sender: self)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        var nib = UINib(nibName: "ChatCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar!)
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("toChat", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: ChatCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as ChatCell
        cell.title.text = titles[indexPath.row]
        cell.message.text = messages[indexPath.row]
        cell.date.text = dates[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toChat"){
            var chatc = segue.destinationViewController as ChatController
            var chatCell = sender as ChatCell
            chatc.receivedTitle = chatCell.title.text
        }
    }
}
