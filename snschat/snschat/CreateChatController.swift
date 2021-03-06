//
//  CreateChatController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit
import SwiftyJSON

class CreateChatController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var subcategoryField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var alertHelper: AlertHelper!
    
    var lastStatusCode = 1
    var data: NSMutableData = NSMutableData()
    var lastOperation: String!
    
    var server: String!
    var user: User!
    
    var categoryPicker: UIPickerView!
    var subcategoryPicker: UIPickerView!
    
    var allCategories: [Category] = [Category]()
    var categories: [Category] = [Category]()
    
    var selectedCategory: Category?
    var selectedSubCategory: Category?
    
    var createdRoom: Room?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertHelper = AlertHelper(viewController: self)
        server = defaults.valueForKey("server") as! String
        
        getAllCategories()
        
        self.categoryPicker = UIPickerView()
        self.categoryPicker.delegate = self
        self.categoryPicker.tag = 0
        
        self.subcategoryPicker = UIPickerView()
        self.subcategoryPicker.delegate = self
        self.subcategoryPicker.tag = 1
        
        self.categoryField.inputView = self.categoryPicker
        self.categoryField.delegate = self
        self.categoryField.tag = 2
        
        self.subcategoryField.inputView = self.subcategoryPicker
        self.subcategoryField.enabled = false
        self.subcategoryField.tag = 3
        
        self.messageField.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.messageField.layer.borderWidth = 0.3
        self.messageField.layer.cornerRadius = 8.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if (textField.tag == 2) {
            self.subcategoryField.enabled = false;
            self.subcategoryField.text = ""
            self.selectedSubCategory = nil
        }
        return true
    }
    
    func getAllCategories() {
        activityIndicator.hidden = false
        
        // create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/api/categories")!)
        request.HTTPMethod = "GET"
    
        lastOperation = "getAllCategories"
        
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return self.categories.count
        }
        else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.selectedCategory!.subcategories != nil && self.categoryField.text != ""){
                return self.selectedCategory!.subcategories!.count
            } else{
                return 0
            }
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return self.categories[row].title
        }
        else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.selectedCategory!.subcategories != nil && self.categoryField.text != ""){
                return self.selectedCategory!.subcategories![row].title
            }
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0 {
            self.categoryField.text = self.categories[row].title
            self.selectedCategory = self.categories[row]
            self.subcategoryField.text = ""
            if (self.categories[row].subcategories != nil && self.categories[row].subcategories!.count > 0) {
                self.subcategoryField.enabled = true
                self.subcategoryPicker.reloadAllComponents()
            }
            else {
                self.subcategoryField.enabled = false
            }
        } else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.selectedCategory!.subcategories!.count > 0 && self.categoryField.text != ""){
                self.subcategoryField.text = self.selectedCategory!.subcategories![row].title
                self.selectedSubCategory = self.selectedCategory!.subcategories![row]
            }
        }
    }
    
    @IBAction func chatAanmaken(sender: UIButton) {
        sender.enabled = false
        if (categoryField.text == "") {
            alertHelper.message("Oeps", message: "Catergorie moet ingevuld zijn!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            sender.enabled = true
        }
        else if (count(messageField.text) < 3) {
            alertHelper.message("Oeps", message: "Bericht moet minsten 3 tekens lang zijn!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            sender.enabled = true
        }
        else {
            activityIndicator.hidden = false
            
            // create the request
            let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/api/rooms")!)
            
            // Set data
            request.HTTPMethod = "POST"
            var category_id : String = ""
            if(self.subcategoryField.text != ""){
                category_id = self.selectedSubCategory!._id!
            } else {
                category_id = self.selectedCategory!._id!
            }
            let postString = "customer=" + self.user!._id! + "&category=" + category_id
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            lastOperation = "createRoom"
            
            if(Reachability.isConnectedToNetwork()){
                let urlConnection = NSURLConnection(request: request, delegate: self)
            } else {
                alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            }
            
            sender.enabled = true
        }
        
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Failed with error:\(error.localizedDescription)")
        if (error.localizedDescription == "The request timed out."){
            alertHelper.message("Oeps", message: "De server is offline, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
    }
    
    //NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSHTTPURLResponse!) {
        //New request so we need to clear the data object
        self.lastStatusCode = response.statusCode;
        self.data = NSMutableData()
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if(self.lastStatusCode == 200){
            switch(lastOperation){
            case "getAllCategories":
                afterGetAllCategories()
            case "createRoom":
                afterCreateRoom()
            case "createMessage":
                afterCreateMessage()
            default:
                println("Default case called in lastOperation switch")
            }
        } else {
            alertHelper.message("Oeps", message: "Er is iets misgegaan op de server, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            println(lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func afterGetAllCategories() {
        let json = JSON(data: self.data)
        for category: JSON in json.arrayValue {
            self.allCategories.append(Category(jsonCategory: category))
        }
        activityIndicator.hidden = true
        
        getCategories()
    }
    
    func getCategories() {
        for category in self.allCategories {
            if (category.parent == nil) { // Als het een hoofdcategorie is
                var subcategories: [Category] = [Category]()
                for c in self.allCategories {
                    if (c.parent != nil && c.parent == category._id) { // Als het een subcategorie is van de hoofdcategorie
                        subcategories.append(c)
                    }
                }
                category.subcategories = subcategories
                self.categories.append(category)
            }
        }
        
        self.categoryField.becomeFirstResponder()
        self.selectedCategory = self.categories[0]
        self.categoryField.text = self.categories[0].title
        self.categoryPicker.selectedRowInComponent(0)
        self.subcategoryField.enabled = true
    }
    
    func afterCreateRoom() {
        let json = JSON(data: self.data)
        self.createdRoom = Room(jsonRoom: json)
        
        // create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/api/rooms/\(self.createdRoom!._id!)/messages")!)
        
        // Set data
        request.HTTPMethod = "POST"
        let postString = "sender=" + self.user!._id! + "&content=" + self.messageField.text
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        lastOperation = "createMessage"
        
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
    }
    
    func afterCreateMessage() {
        let json = JSON(data: self.data)
        var createdMessage = Message(message: json)
        
        self.createdRoom!.messages?.append(createdMessage)
        user!.rooms.append(self.createdRoom!)
        
        activityIndicator.hidden = true
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onTapMainView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}
