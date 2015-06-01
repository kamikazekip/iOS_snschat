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
    
    var picker: UIImagePickerController? = UIImagePickerController()
    var popover: UIPopoverController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker!.delegate = self
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
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage!
        //sets the selected image to image view
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("picker cancel.")
    }
    
}
