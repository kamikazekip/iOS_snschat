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
        self.alpha = 0.0
        self.on()
    }
    
    private func on(){
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.isTypingLabel!.alpha = 1.0
            }, completion: { ( finished: Bool) -> Void in
                self.off()
        })
    }
    
    private func off(){
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.isTypingLabel!.alpha = 0.05
            }, completion: { ( finished: Bool) -> Void in
                self.on()
        })
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
