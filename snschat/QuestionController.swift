//
//  QuestionController.swift
//  snschat
//
//  Created by Erik Brandsma on 17/06/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import UIKit

class QuestionController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    var ownFAQ: FAQ!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionLabel.layer.borderWidth = 0.5
        self.questionLabel.layer.borderColor = UIColor.grayColor().CGColor
        self.answerLabel.layer.borderWidth = 0.5
        self.answerLabel.layer.borderColor = UIColor.grayColor().CGColor
        
        self.questionTextView.text = ownFAQ.question
        self.answerTextView.text = ownFAQ.answer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
