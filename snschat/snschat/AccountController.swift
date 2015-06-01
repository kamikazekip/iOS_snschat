//
//  AccountController.swift
//  snschat
//
//  Created by User on 01/06/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import UIKit

class AccountController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnAfbeeldingWijzigen: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var picker: UIImagePickerController? = UIImagePickerController()
    var popover: UIPopoverController? = nil
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var alertHelper: AlertHelper!
    
    var lastStatusCode = 1
    var data: NSMutableData = NSMutableData()
    var lastOperation: String!
    
    var server: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker!.delegate = self
        
        alertHelper = AlertHelper(viewController: self)
        server = defaults.valueForKey("server") as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeImage(sender: UIButton) {
        var alert:UIAlertController = UIAlertController(title: "Selecteer afbeelding", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openCamera()
        }
        
        var gallaryAction = UIAlertAction(title: "Galerij", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openGallary()
        }
        
        var removeAction = UIAlertAction(title: "Verwijderen", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.removeImage()
        }
        
        var cancelAction = UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        
        // Present the actionsheet
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.popover = UIPopoverController(contentViewController: alert)
            self.popover!.presentPopoverFromRect(self.btnAfbeeldingWijzigen.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            self.picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(self.picker!, animated: true, completion: nil)
        }
        else {
            openGallary()
        }
    }
    
    func openGallary() {
        self.picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(self.picker!, animated: true, completion: nil)
        }
        else {
            self.popover = UIPopoverController(contentViewController: self.picker!)
            self.popover!.presentPopoverFromRect(btnAfbeeldingWijzigen.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func removeImage() {
        println("Remove image")
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage!
        self.imageView.image = image
        
        /*activityIndicator.hidden = false
        
        // Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(server)/api/avatar")!)
        request.HTTPMethod = "POST"
        
        //var imageData = UIImageJPEGRepresentation(image, 0.9)
        //var base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!) // encode the image
        
        //var err: NSError? = nil
        //var params = ["image":[ "content_type": "image/jpeg", "filename":"test.jpg", "file_data": base64String]]
        
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(0), error: &err)!
            
        lastOperation = "uploadImage"
        
        if(Reachability.isConnectedToNetwork()){
            let urlConnection = NSURLConnection(request: request, delegate: self)
        } else {
            alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }*/
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("picker cancel.")
    }
    
    // NSURLConnection delegate method
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Failed with error:\(error.localizedDescription)")
        if (error.localizedDescription == "The request timed out."){
            alertHelper.message("Oeps", message: "De server is offline, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
    }
    
    // NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSHTTPURLResponse!) {
        //New request so we need to clear the data object
        self.lastStatusCode = response.statusCode;
        self.data = NSMutableData()
    }
    
    // NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
    // NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if(self.lastStatusCode == 200){
            switch(lastOperation){
            case "uploadImage":
                afterUploadImage()
            default:
                println("Default case called in lastOperation switch")
            }
        } else {
            alertHelper.message("Oeps", message: "Er is iets misgegaan op de server, probeer het later nog eens!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
            println(lastStatusCode)
            println("Something went wrong, statusCode wasn't 200")
        }
    }
    
    func afterUploadImage() {
        activityIndicator.hidden = true
    }
}
