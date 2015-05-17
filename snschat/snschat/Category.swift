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
    var parent: Category?
    var subcategories: [Category]?
    
    init(jsonCategory category: JSON) {
        
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
        if let parent = category["parent"] as JSON? {
            self.parent = Category(jsonCategory: parent)
        }
    }
    
}
