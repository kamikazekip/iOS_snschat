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
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    @IBAction func inloggen(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        defaults.setValue(debugField.text, forKey: "server")
    }
}

