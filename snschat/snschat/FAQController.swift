//
//  FAQController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import SwiftyJSON

class FAQController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var alertHelper: AlertHelper!
    
    var lastStatusCode = 1
    var data: NSMutableData = NSMutableData()
    var lastOperation: String!
    
    var server: String!
    
    var allFAQ: [FAQ] = [FAQ]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertHelper = AlertHelper(viewController: self)
        self.server = defaults.valueForKey("server") as! String
        
        getFAQ()
        
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allFAQ.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("categoryCell") as! CategoryCell
        if (self.allFAQ[indexPath.row].category!.parent == nil) {
            cell.category.text = self.allFAQ[indexPath.row].category!.title
        }
        
        return cell
    }
    
    // NSURLConnection delegate method
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Failed with error:\(error.localizedDescription)")
        if (error.localizedDescription == "The request timed out."){
            self.alertHelper.message("Oeps", message: "De server is offline, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
    }
    
    // NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSHTTPURLResponse!) {
        //New request so we need to clear the data object
        self.lastStatusCode = response.statusCode;
        self.data = NSMutableData()
    }
    
    // NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
    // NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if(self.lastStatusCode == 200){
            switch(lastOperation){
            case "getFAQ":
                afterGetFAQ()
            default:
                println("Default case called in lastOperation switch")
            }
        } else {
            self.alertHelper.message("Oeps", message: "Er is iets misgegaan op de server, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            println(self.lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func getFAQ() {
        self.activityIndicator.hidden = false
        
        // Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/api/faqs")!)
        request.HTTPMethod = "GET"
        
        self.lastOperation = "getFAQ"
        
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            self.alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
    }
    
    func afterGetFAQ() {
        let json = JSON(data: self.data)
        for faq: JSON in json.arrayValue {
            self.allFAQ.append(FAQ(jsonFAQ: faq))
        }
        self.activityIndicator.hidden = true
        self.tableView.reloadData()
    }

}


