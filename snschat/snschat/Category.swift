//
//  File.swift
//  snschat
//
//  Created by User on 11/05/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import Foundation

class Category {
    
    var _id: String?
    var category: String?
    var subCategories: [Subcategory] = [Subcategory]()
    
    init(){
        category = "hurrdurr"
        subCategories.append(Subcategory())
        subCategories.append(Subcategory())
    }
}
