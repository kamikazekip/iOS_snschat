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
    
    var server: String!
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker!.delegate = self
        
        alertHelper = AlertHelper(viewController: self)
        server = defaults.valueForKey("server") as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        username = defaults.valueForKey("userID") as! String
        getCurrentAvatar()
    }
    
    func getCurrentAvatar() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            var newUrl = "\(self.server)/public/img/profile/\(self.username).jpg".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            if let url = NSURL(string: newUrl) {
                if let data = NSData(contentsOfURL: url){
                    if let imageFromUrl = UIImage(data: data) {
                        self.imageView!.image = imageFromUrl
                        self.activityIndicator.hidden = true
                    }
                }
            }
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
       
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
        
        var cancelAction = UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker .dismissViewControllerAnimated(true, completion: nil)
        
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage!
        self.imageView.image = image
        
        activityIndicator.hidden = false
        
        if(Reachability.isConnectedToNetwork()){
            uploadImageOne(image)
        } else {
            alertHelper.message("Oeps", message: "U bent niet verbonden met het internet!", style: UIAlertActionStyle.Destructive, buttonMessage: "OK")
        }
        
        activityIndicator.hidden = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadImageOne(image: UIImage) {
        
        var imageData = UIImagePNGRepresentation(image)
        
        var request = NSMutableURLRequest(URL: NSURL(string: "\(server)/api/avatar")!)
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        var boundary = NSString(format: "---------------------------14737809831466499882746641449")
        var contentType = NSString(format: "multipart/form-data; boundary=%@", boundary)
        
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        
        var body = NSMutableData.alloc()
        
        // Image
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"" + self.username + "\"; filename=\"" + self.username + ".jpg\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData)
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        println("voor request")
        println(NSString(data: body, encoding: NSUTF8StringEncoding))
        println("na request")
        
        request.HTTPBody = body
        
        NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    }
}
