//
//  RegistrerenController.swift
//  snschat
//
//  Created by Erik Brandsma on 12/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class RegistrerenController: UIViewController {
  
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordField2: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var loginController: LoginController!
    var lastEmail: String!
    var alertHelper: AlertHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertHelper = AlertHelper(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        emailField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func register(sender: UIButton) {
        var email = emailField.text
        var password = passwordField.text
        var confirm = passwordField2.text
        if(email.isEmpty || password.isEmpty || confirm.isEmpty){
            alertHelper.message("Oeps", message: "Alle velden moeten ingevuld zijn!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            passwordField.text = ""
            passwordField2.text = ""
        }
        else if(password != confirm){
            alertHelper.message("Oeps", message: "Het bevestig wachtwoord komt niet overeen met het wachtwoord!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            passwordField.text = ""
            passwordField2.text = ""
        }
        else if(count(password) < 3 || count(email) < 3){
            alertHelper.message("Oeps", message: "Email en wachtwoord moeten beide 3 of meer karakters bevatten!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
        else if(!isValidEmail(email)){
            alertHelper.message("Oeps", message: "Het opgegeven e-mailadres moet geldig zijn!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
        else {
            self.registerButton.enabled = false
            self.view.endEditing(true)
            activityIndicator.hidden = false
            var user = User(email: emailField.text, password: passwordField.text)
            lastEmail = email
            user.register(self);
        }
    }
    
    func afterRegister(){
        activityIndicator.hidden = true
        self.registerButton.enabled = true
        var alertController = UIAlertController(title: "Gelukt!", message: "\(lastEmail) is geregistreerd!", preferredStyle: .Alert)
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.goToLogin()
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func error(text: String){
        alertHelper.message("Oeps", message: text, style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        activityIndicator.hidden = true
        self.registerButton.enabled = true
    }
    
    func goToLogin(){
        loginController.emailField.text = lastEmail
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func clearInputs() {
        emailField.text = ""
        passwordField.text = ""
        passwordField2.text = ""
        self.registerButton.enabled = true
    }
}
