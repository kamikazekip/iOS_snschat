//
//  ChatAanmakenController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatAanmakenController: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var subcategoryField: UITextField!
    
    var categoryPicker: UIPickerView!
    var subcategoryPicker: UIPickerView!
    
    var categories = ["Categorie 1", "Categorie 2", "Categorie 3", "Categorie 4", "Categorie 5", "Categorie 6", "Categorie 7"]
    var subcategories = ["Subcategorie 1", "Subcategorie 2", "Subcategorie 3", "Subcategorie 4", "Subcategorie 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryPicker = UIPickerView()
        self.categoryPicker.delegate = self
        self.categoryPicker.tag = 0
        
        self.subcategoryPicker = UIPickerView()
        self.subcategoryPicker.delegate = self
        self.subcategoryPicker.tag = 1
        
        self.categoryField.inputView = self.categoryPicker
        self.subcategoryField.inputView = self.subcategoryPicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return self.categories.count
        }
        else if pickerView.tag == 1 {
            return self.subcategories.count
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return self.categories[row]
        }
        else if pickerView.tag == 1 {
            return self.subcategories[row]
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0 {
            self.categoryField.text = self.categories[row]
        } else if pickerView.tag == 1 {
            self.subcategoryField.text = self.subcategories[row]
        }
    }
    
    @IBAction func onTapMainView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}
