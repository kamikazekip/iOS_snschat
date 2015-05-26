//
//  ChatBubble.swift
//  snschat
//
//  Created by Erik Brandsma on 07/04/15.
//  Copyright (c) 2015 Erik Brandsma. All rights reserved.
//

import UIKit

class ChatBubble: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        message.numberOfLines = 0
        message.sizeToFit()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
