//
//  QuestionCell.swift
//  snschat
//
//  Created by Erik Brandsma on 17/06/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var question: UILabel!
    var ownFAQ: FAQ!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
