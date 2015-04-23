//
//  AlertHelper.swift
//  snschat
//
//  Created by Erik Brandsma on 23/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class AlertHelper {
    
    var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func message(title: String, message: String, style: UIAlertActionStyle, buttonMessage: String){
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonMessage, style: style, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}