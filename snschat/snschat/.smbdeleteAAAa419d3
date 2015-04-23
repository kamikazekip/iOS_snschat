//
//  User.swift
//  snschat
//
//  Created by Erik Brandsma on 23/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import Foundation

class User: NSObject, NSURLConnectionDelegate {
    var lastStatusCode = 1
    var data: NSMutableData = NSMutableData()
    var lastOperation: String!
    var email: String!
    var password: String!
    var registerController: RegistrerenController?
    var defaults = NSUserDefaults.standardUserDefaults()
    var server: String!
    
    init(email: String, password: String){
        self.email = email
        self.password = password
        server = defaults.valueForKey("server") as! String
    }
    
    func register(registerController: RegistrerenController!){
        self.registerController = registerController
        
        // create the request
        println(server)
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
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Failed with error:\(error.localizedDescription)")
        if(lastOperation == "register" && error.localizedDescription == "The request timed out." ){
            registerController!.error("De server is offline")
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
        //Append incoming data
        self.data.appendData(data)
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if(self.lastStatusCode == 200){
            switch(lastOperation){
            case "register":
                afterRegister()
            default:
                println("Default case called in lastOperation switch")
            }
        } else {
            if(lastOperation == "register"){
                registerController!.error("Er is iets misgegaan op de server, probeer het later nog eens!")
            }
            println(data)
            println(lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func afterRegister(){
        self.registerController?.afterRegister()
    }
}
