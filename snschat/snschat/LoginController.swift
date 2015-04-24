//
//  ViewController.swift
//  snschat
//
//  Created by Erik Brandsma on 12/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    
    @IBOutlet weak var debugField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var alertHelper: AlertHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertHelper = AlertHelper(viewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Inloggen"
        var link: String? = defaults.valueForKey("server") as! String?
        if (link == nil ) {
            defaults.setValue("http://snschat.compuplex.nl", forKey: "server")
            link = "http://snschat.compuplex.nl"
        }
        debugField.text = link
    }

    override func viewDidAppear(animated: Bool) {
        if(count(emailField.text) == 0){
            emailField.becomeFirstResponder()
        } else {
            passwordField.becomeFirstResponder()
        }
    }
    
    @IBAction func onScrollTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "inloggenKnop"){
            self.navigationItem.title = "Uitloggen"
        } else if(segue.identifier == "toRegister"){
            var newController = segue.destinationViewController as! RegistrerenController
            newController.loginController = self
        }
    }
    @IBAction func inloggen(sender: UIButton) {
        var email = emailField.text
        var password = passwordField.text
        if(email.isEmpty || password.isEmpty){
            alertHelper.message("Oeps", message: "Alle velden moeten ingevuld zijn!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            passwordField.text = ""
        }
        else if(count(password) < 3 || count(email) < 3){
            alertHelper.message("Oeps", message: "Email en wachtwoord moeten beide 3 of meer karakters bevatten!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
        else {
            self.loginButton.enabled = false
            self.view.endEditing(true)
            activityIndicator.hidden = false
            var user = User(email: emailField.text, password: passwordField.text)
            user.login(self);
        }
    }
    
    func error(text: String){
        alertHelper.message("Oeps", message: text, style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        activityIndicator.hidden = true
        self.loginButton.enabled = true
    }
    
    func afterLogin() {
        activityIndicator.hidden = true
        self.loginButton.enabled = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        defaults.setValue(debugField.text, forKey: "server")
    }
}
