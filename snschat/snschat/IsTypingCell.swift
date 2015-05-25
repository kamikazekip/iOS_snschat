//
//  TableViewCell.swift
//  snschat
//
//  Created by User on 25/05/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import UIKit

class IsTypingCell: UITableViewCell {

    @IBOutlet weak var isTypingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
