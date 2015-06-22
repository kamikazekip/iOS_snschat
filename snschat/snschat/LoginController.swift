//
//  ViewController.swift
//  snschat
//
//  Created by Erik Brandsma and Jip Verhoeven on 12/03/15.
//  Copyright (c) 2015 Erik Brandsma and Jip Verhoeven. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    var text: String?
    var chatsController: ChatsController!

	var user: User?
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var alertHelper: AlertHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.setValue("http://snschat.compuplex.nl", forKey: "server")
        alertHelper = AlertHelper(viewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Inloggen"
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

		// TODO: Deze lijkt niet af te gaan voor het inloggen, dit moet wel want
		//		 de functie setCurrentUser (paar regels hieronder) moet uitgevoerd
		//		 worden. Op het moment wordt de ChatsController dus geopend zonder
		//		 een user object, wat alles verpest.

        if(segue.identifier == "inloggenKnop"){
            self.navigationItem.title = "Uitloggen"
  
			// User doorgeven
			let chatsController = segue.destinationViewController as! ChatsController
			chatsController.setCurrentUser(self.user!)

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
            alertHelper.message("Oeps", message: "Gebruikersnaam en wachtwoord moeten beide 3 of meer karakters bevatten!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
        else {
            self.loginButton.enabled = false
            self.view.endEditing(true)

            activityIndicator.hidden = false

			// User aanmaken en laten inloggen
            self.user = User(email: emailField.text, password: passwordField.text)
            self.user!.login(self);
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
        defaults.setBool(true, forKey: "fromLogin")
        
        /* TODO
        geef self.chatsController VOOR de segue hieronder alle properties die nodig zijn!
        */
        self.chatsController.user = self.user
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

