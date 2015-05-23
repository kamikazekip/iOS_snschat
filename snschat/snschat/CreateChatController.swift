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
        
        self.subcategoryField.inputView = self.subcategoryPicker
        self.subcategoryField.enabled = false
        
        self.messageField.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.messageField.layer.borderWidth = 0.3
        self.messageField.layer.cornerRadius = 8.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.categoryField.becomeFirstResponder()
        self.categoryPicker.selectedRowInComponent(0)
        ////self.selectedCategory = self.categories[0]
        //self.subcategoryField.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        self.subcategoryField.enabled = false
        self.subcategoryField.text = ""
        return true
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
            self.subcategoryField.enabled = true
            self.subcategoryPicker.reloadAllComponents()
        } else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.selectedCategory!.subcategories != nil && self.categoryField.text != ""){
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
            
            /*// create the request
            let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/rooms")!)
            
            // Set data
            request.HTTPMethod = "POST"
            let postString = "user=" + self.user!._id + "&category=" + self.selectedCategory._id + "&subcategory=" + self.selectedSubCategory._id + "message=" + self.messageField.text
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            
            lastOperation = "createChat"
            
            if(Reachability.isConnectedToNetwork()){
                let urlConnection = NSURLConnection(request: request, delegate: self)
            } else {
                alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            }*/
            
            
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
            case "createChat":
                afterCreateChat()
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
        
        self.selectedCategory = self.categories[0]
    }
    
    func afterCreateChat() {
        
    }
    
    @IBAction func onTapMainView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}
