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
    var loginController: LoginController!
    var lastEmail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func back(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func register(sender: UIButton) {
        var email = emailField.text
        var password = passwordField.text
        var confirm = passwordField2.text
        if(email.isEmpty || password.isEmpty || confirm.isEmpty){
            var alert = UIAlertController(title: "Oeps!", message: "Alle velden moeten ingevuld zijn!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            passwordField.text = ""
            passwordField2.text = ""
        }
        else if(password != confirm){
            var alert = UIAlertController(title: "Oeps!", message: "Het bevestig wachtwoord komt niet overeen met het wachtwoord!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            passwordField.text = ""
            passwordField2.text = ""
        }
        else if(count(password) < 3 || count(email) < 3){
            var alert = UIAlertController(title: "Oeps!", message: "Email en wachtwoord moeten beide 3 of meer karakters bevatten!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if(!isValidEmail(email)){
            var alert = UIAlertController(title: "Oeps!", message: "Het opgegeven e-mailadres moet geldig zijn!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.view.endEditing(true)
            activityIndicator.hidden = false
            var user = User(email: emailField.text, password: passwordField.text)
            lastEmail = email
            user.register(self);
        }
    }
    
    func afterRegister(){
        activityIndicator.hidden = true
        var alertController = UIAlertController(title: "Gelukt!", message: "\(lastEmail) is geregistreerd!", preferredStyle: .Alert)
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.goToLogin()
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func error(message: String){
        var alert = UIAlertController(title: "Oeps!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        activityIndicator.hidden = true
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
}
