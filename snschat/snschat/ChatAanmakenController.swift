//
//  ChatAanmakenController.swift
//  snschat
//
//  Created by Erik Brandsma on 19/03/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatAanmakenController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var subcategoryField: UITextField!
    
    var categoryPicker: UIPickerView!
    var subcategoryPicker: UIPickerView!
    
    var categories: [Category] = [Category]()
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories.append(Category())
        categories.append(Category())
        
        self.categoryPicker = UIPickerView()
        self.categoryPicker.delegate = self
        self.categoryPicker.tag = 0
        
        self.subcategoryPicker = UIPickerView()
        self.subcategoryPicker.delegate = self
        self.subcategoryPicker.tag = 1
        
        self.categoryField.inputView = self.categoryPicker
        self.categoryField.delegate = self
        self.subcategoryField.inputView = self.subcategoryPicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        println("HOI")
        return true
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return self.categories.count
        }
        else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.categoryField.text != ""){
                return self.selectedCategory!.subCategories.count
            } else{
                return 0
            }
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return self.categories[row].category
        }
        else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.categoryField.text != ""){
                return self.selectedCategory!.subCategories[row].subcategory
            }
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0 {
            self.categoryField.text = self.categories[row].category
            self.selectedCategory = self.categories[row]
        } else if pickerView.tag == 1 {
            if(self.selectedCategory != nil && self.categoryField.text != ""){
                self.subcategoryField.text = self.selectedCategory!.subCategories[row].subcategory
            }
        }
    }
    
    @IBAction func onTapMainView(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
}
