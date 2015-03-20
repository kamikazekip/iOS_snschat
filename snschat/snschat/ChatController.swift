//
//  ChatController.swift
//  snschat
//
//  Created by Jip Verhoeven on 20/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatController: UIViewController {

    var receivedTitle: String!
    
    @IBOutlet weak var titleBarTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBarTitle.title = receivedTitle
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
