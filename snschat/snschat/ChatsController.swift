//
//  ChatsController.swift
//  snschat
//
//  Created by Erik Brandsma on 13/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var chat: NSMutableArray! = NSMutableArray()
    var subtitles: NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chat.addObject("Waarom kan ik niet connecten?")
        self.chat.addObject("Deze telefoon gaat niet meer aan")
        self.subtitles.addObject("Probeer eens om wi-fi aan en uit te zetten.")
        self.subtitles.addObject("Wacht eens, hoe kun je dan nu chatten?")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chat.count
 
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = chat.objectAtIndex(indexPath.row) as? String
        //cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.detailTextLabel?.numberOfLines = 0;
        cell.detailTextLabel?.setTranslatesAutoresizingMaskIntoConstraints(true);
        cell.detailTextLabel?.text = subtitles.objectAtIndex(indexPath.row) as? String
        return cell
    }
}
