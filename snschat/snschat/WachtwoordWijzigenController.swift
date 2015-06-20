//
//  WachtwoordWijzigenController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class WachtwoordWijzigenController: UIViewController, NSURLConnectionDelegate {
    
    var username: String!
    var password: String!
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var alertHelper: AlertHelper!
    var lastOperation: String = ""
    var server: String!
    var lastStatusCode: Int!
    
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordRepeat: UITextField!

    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username = defaults.stringForKey("userID")
        self.password = defaults.stringForKey("password")
        self.server = defaults.valueForKey("server") as! String
        self.alertHelper = AlertHelper(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.oldPassword.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func change(sender: UIButton) {
        var oldPass         = oldPassword.text
        var newPass         = newPassword.text
        var newPassRepeat   = newPasswordRepeat.text
        
        if(oldPass.isEmpty || newPass.isEmpty || newPassRepeat.isEmpty){
            alertHelper.message("Oeps", message: "Alle velden moeten ingevuld zijn!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            oldPassword.text = ""
            newPassword.text = ""
            newPasswordRepeat.text = ""
        }
        else if(newPass != newPassRepeat){
            alertHelper.message("Oeps", message: "Het bevestig wachtwoord komt niet overeen met het wachtwoord!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            oldPassword.text = ""
            newPassword.text = ""
            newPasswordRepeat.text = ""
        }
        else if(count(newPass) < 3 || count(newPassRepeat) < 3 || count(oldPass) < 3){
            alertHelper.message("Oeps", message: "Alle velden moeten 3 of meer karakters bevatten!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
        else {
            if(oldPass == self.password){
                self.changeButton.enabled = false
                activityIndicator.hidden = false
                self.view.endEditing(true)
                changePass(newPass)
            } else {
                alertHelper.message("Oeps", message: "Uw oude wachtwoord komt niet overeen", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
                oldPassword.text = ""
                newPassword.text = ""
                newPasswordRepeat.text = ""
            }
            
        }
    }
    
    func changePass(newPass: String){
        self.lastOperation = "changePass"
        var url: String = "\(self.server)/api/users/\(self.username)"
        // Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "PUT"
        var postString = "{ \"password\": \"\(newPass)\" }"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            self.alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
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
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if(self.lastStatusCode == 200){
            switch(lastOperation){
            case "changePass":
                afterChangePass()
            default:
                println("Default case called in lastOperation switch")
            }
        } else {
            alertHelper.message("Oeps", message: "Er is iets misgegaan op de server, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            println(lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func afterChangePass(){
        activityIndicator.hidden = true
        changeButton.enabled = true
        
        var alertController = UIAlertController(title: "Gelukt!", message: "Uw wachtwoord is gewijzigd, dit gaat in effect bij de volgende keer inloggen", preferredStyle: .Alert)
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
