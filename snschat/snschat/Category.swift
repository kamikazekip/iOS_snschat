//
//  File.swift
//  snschat
//
//  Created by User on 11/05/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import Foundation
import SwiftyJSON

class Category {
    
    var _id: String?
    var title: String?
    var description: String?
    var parent: String?
    var subcategories: [Category]!
    var allFAQs : [FAQ]!
    
    init(jsonCategory category: JSON) {
        
        self.allFAQs = [FAQ]()
        self.subcategories = [Category]()
        
        // Vul id
        if let _id = category["_id"].string {
            self._id = _id
        }
        
        // Vul title
        if let title = category["title"].string {
            self.title = title
        }
        
        // Vul description
        if let description = category["description"].string {
            self.description = description
        }
        
        // Vul parent
        if let parent = category["parent"].string {
            self.parent = parent
        }
    }
    
    func injectFAQ(faq: FAQ){
        self.allFAQs.append(faq)
    }
    
    func hasFAQs() -> Bool{
        var has = false
        for subCategorie: Category in self.subcategories! {
            if(subCategorie.hasFAQs()){
                has = true
            }
        }
        if(self.subcategories?.count > 0){
            has = true
        }
        return has
    }
}
