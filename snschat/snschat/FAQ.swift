//
//  FAQ.swift
//  snschat
//
//  Created by Erik Brandsma on 27/05/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import Foundation
import SwiftyJSON

class FAQ {
    
    var _id: String?
    var question: String?
    var category: Category?
    var answer: String?
    
    init(jsonFAQ faq: JSON) {
        
        // Vul id
        if let _id = faq["_id"].string {
            self._id = _id
        }
        
        // Vul question
        if let question = faq["question"].string {
            self.question = question
        }
        
        // Vul category
        if let category = faq["category"] as JSON? {
            self.category = Category(jsonCategory: category)
            println("FAQ \(self.category!.title)")
        }
        
        // Vul answer
        if let answer = faq["answer"].string {
            self.answer = answer
        }
        
    }
    
    
}
