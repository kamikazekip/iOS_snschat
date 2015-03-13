//
//  ViewController.swift
//  snschat
//
//  Created by Erik Brandsma on 12/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    }
    
    @IBAction func onScrollTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "inloggenKnop"){
            self.navigationItem.title = "Uitloggen"
        }
    }
}

