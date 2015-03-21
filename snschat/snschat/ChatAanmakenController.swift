//
//  ChatAanmakenController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatAanmakenController: UIViewController {

    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var subcategoryPicker: UIPickerView!
    
    var categoryController: CategorieController!
    var subcategoryController: SubcategorieController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryController = CategorieController()
        
        categoryPicker.dataSource = categoryController
        categoryPicker.delegate = categoryController

        subcategoryController = SubcategorieController()
        
        subcategoryPicker.dataSource = subcategoryController
        subcategoryPicker.delegate = subcategoryController
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapMainView(sender: AnyObject) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
