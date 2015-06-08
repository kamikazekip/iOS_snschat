//
//  ImageBubble.swift
//  snschat
//
//  Created by Gideon Spierings on 08-06-15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import UIKit

class ImageBubble: UITableViewCell {

	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var _imageView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}