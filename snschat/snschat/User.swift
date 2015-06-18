//
//  User.swift
//  snschat
//
//  Created by Erik Brandsma on 23/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: NSObject, NSURLConnectionDelegate {

	// Properties
	var _id: String?
	var lastLogin: String?
	var roles: [String]
	var rooms: [Room]

    var lastStatusCode = 1
    var data: NSMutableData = NSMutableData()
    var lastOperation: String!
    var email: String!
    var password: String!
    var registerController: RegistrerenController?
    var loginController: LoginController?
    var defaults = NSUserDefaults.standardUserDefaults()
    var server: String!
    
    init(email: String, password: String){
        self.email = email
        self.password = password
        server = defaults.valueForKey("server") as! String

		self.roles = [String]()
		self.rooms = [Room]()
    }

	init (jsonUser user: JSON) {
		self.roles = [String]()
		self.rooms = [Room]()

		// super.init() hier omdat ie anders gaat janken. Rare shit
		// Laat even weten als je een oplossing vind, dit is lelijk
		// en ik ben benieuwd.
		super.init()

		// Vul die props. Beetje lelijke functie maar komt doordat ie
		// op meerdere plekken gebruikt moet worden atm.
		self.fillProps(user)
	}
    
    func register(registerController: RegistrerenController!){
        self.registerController = registerController
        
        // create the request
        let url = NSURL(string: "\(server)/api/users")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "_id=" + self.email + "&password=" + self.password
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        lastOperation = "register"
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            registerController.error("U bent niet verbonden met het internet!")
        }
    }
    
    func login(loginController: LoginController!){
        self.loginController = loginController

		// create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/login")!)

		// Set data
        request.HTTPMethod = "POST"
        let postString = "username=" + self.email + "&password=" + self.password
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        lastOperation = "login"

        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            loginController.error("U bent niet verbonden met het internet!")
        }
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Failed with error:\(error.localizedDescription)")
        if(lastOperation == "register"){
            registerController!.error("Kan geen verbinding maken met de server! Controleer uw internetconnectie")
        } else  if( lastOperation == "login"){
            loginController!.error("Kan geen verbinding maken met de server! Controleer uw internetconnectie")
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
            case "register":
                afterRegister()
            case "login":
                afterLogin()
            default:
                println("Default case called in lastOperation switch")
            }
        } else if (self.lastStatusCode == 409) {
            if(lastOperation == "register"){
                registerController!.error("Het e-mailadres is al in gebruik!")
                registerController!.clearInputs()
            }
        } else if (self.lastStatusCode == 403) {
            if(lastOperation == "login"){
                loginController!.error("Foute e-mail en wachtwoord combinatie!")
            }
        } else {
            var errorMessage = "Er is iets misgegaan op de server, probeer het later nog eens!"
            if(lastOperation == "register"){
                registerController!.error(errorMessage)
            } else if (lastOperation == "login") {
                loginController!.error(errorMessage)
            }
            println(lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func afterRegister(){
        self.registerController?.afterRegister()
    }
    
    func afterLogin() {
        // Converteer result naar json
        let json = JSON(data: self.data)
        
        // Functie om de properties te vullen dmv een JSON object. Reden
        // voor deze functie is omdat hij op meerdere plekken gebruikt
        // wordt. Na het opruimen van deze class is het misschien niet
        // meer nodig.
        fillProps(json["user"])
        defaults.setObject(self._id, forKey: "userID")
        defaults.setObject(self.password, forKey: "password")
        
        self.loginController?.afterLogin()
    }

	func fillProps(json: JSON) {
		// Vul _id
		if let username = json["_id"].string {
			self._id = username
		}

		// Vul lastlogin
		if let lastLogin = json["lastLogin"].string {
			self.lastLogin = lastLogin
		}

		// Vul rooms
		for room: JSON in json["rooms"].arrayValue {
			self.rooms.append(Room(jsonRoom: room))
		}

		// Vul roles
		for role: JSON in json["roles"].arrayValue {
			self.roles.append(role.stringValue)
		}
        
	}
}
