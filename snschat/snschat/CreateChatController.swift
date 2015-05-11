//
//  CreateChatController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

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
    
    var categories: [Category] = [Category]()
    var selectedCategory: Category?
    var selectedSubCategory: Subcategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories.append(Category())
        categories.append(Category())
        
        alertHelper = AlertHelper(viewController: self)
        server = defaults.valueForKey("server") as! String
        
        self.categoryPicker = UIPickerView()
        self.categoryPicker.delegate = self
        self.categoryPicker.tag = 0
        
        self.subcategoryPicker = UIPickerView()
        self.subcategoryPicker.delegate = self
        self.subcategoryPicker.tag = 1
        
        self.categoryField.inputView = self.categoryPicker
        self.categoryField.delegate = self
        self.subcategoryField.inputView = self.subcategoryPicker
        
        self.messageField.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.messageField.layer.borderWidth = 0.3
        self.messageField.layer.cornerRadius = 8.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.categoryField.becomeFirstResponder()
        self.categoryField.text = self.categories[0].category
        self.categoryPicker.selectedRowInComponent(0)
        self.selectedCategory = self.categories[0]
        self.subcategoryField.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            if(self.selectedCategory != nil && self.categoryField.text != ""){
                return self.selectedCategory!.subCategories.count
            } else{
                return 0
            }
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return self.categories[row].category
        }
        else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.categoryField.text != ""){
                return self.selectedCategory!.subCategories[row].subcategory
            }
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0 {
            self.categoryField.text = self.categories[row].category
            self.selectedCategory = self.categories[row]
            self.subcategoryField.enabled = true
        } else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.categoryField.text != ""){
                self.subcategoryField.text = self.selectedCategory!.subCategories[row].subcategory
                self.selectedSubCategory = self.selectedCategory?.subCategories[row]
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
            
            lastOperation = "chatAanmaken"
            
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
            case "chatAanmaken":
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
    
    func afterCreateChat() {
        
    }
    
    @IBAction func onTapMainView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}
