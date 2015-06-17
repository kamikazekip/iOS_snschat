//
//  FAQQuestionController.swift
//  snschat
//
//  Created by Erik Brandsma on 17/06/15.
//  Copyright (c) 2015 nl.avans. All rights reserved.
//

import UIKit

class FAQQuestionController: UIViewController {

    @IBOutlet weak var subcategoryTable: UITableView!
    @IBOutlet weak var questionTable: UITableView!
    @IBOutlet weak var titleBarTitle: UINavigationItem!
    
    @IBOutlet weak var subcategoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var selectedSubIndex: NSIndexPath?
    var selectedQuestionIndex: NSIndexPath?
    
    var category: Category!
    var subcategoryTableTag = 0
    var questionTableTag = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subcategoryTable.tag = subcategoryTableTag
        questionTable.tag = questionTableTag
        
        var backgroundView = UIView(frame: CGRectZero)
        self.subcategoryTable.tableFooterView = backgroundView
        self.subcategoryTable.backgroundColor = UIColor.whiteColor()
        self.questionTable.tableFooterView = backgroundView
        self.questionTable.backgroundColor = UIColor.whiteColor()
        self.titleBarTitle.title = self.category.title!
        
        self.subcategoryLabel.layer.borderWidth = 0.5
        self.subcategoryLabel.layer.borderColor = UIColor.grayColor().CGColor
        self.questionLabel.layer.borderWidth = 0.5
        self.questionLabel.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if(self.selectedSubIndex != nil){
            self.subcategoryTable.deselectRowAtIndexPath(self.selectedSubIndex!, animated: true)
        }
        if(self.selectedQuestionIndex != nil){
            self.questionTable.deselectRowAtIndexPath(self.selectedQuestionIndex!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (tableView.tag == subcategoryTableTag) {
            var label = UILabel(frame: CGRectMake(0, 0, self.subcategoryTable.bounds.size.width, self.subcategoryTable.bounds.size.height))
            if (self.category.subcategories.count == 0) {
                label.text = "Deze categorie heeft geen subcategorieen."
                label.textAlignment = NSTextAlignment.Center
                label.numberOfLines = 0
                self.subcategoryTable.backgroundView = label
                return 0
            } else {
                self.subcategoryTable.backgroundView = nil
            }
        } else if (tableView.tag == questionTableTag) {
            var label = UILabel(frame: CGRectMake(0, 0, self.questionTable.bounds.size.width, self.questionTable.bounds.size.height))
            if (self.category.allFAQs.count == 0) {
                label.text = "Deze categorie heeft geen vragen."
                label.textAlignment = NSTextAlignment.Center
                label.numberOfLines = 0
                self.questionTable.backgroundView = label
                return 0
            }
            else {
                self.questionTable.backgroundView = nil
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == subcategoryTableTag){
            return self.category.subcategories.count
        } else if (tableView.tag == questionTableTag){
            return self.category.allFAQs.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView.tag == subcategoryTableTag){
            self.selectedSubIndex = indexPath
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        } else if (tableView.tag == questionTableTag){
            self.selectedQuestionIndex = indexPath
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(tableView.tag == subcategoryTableTag){
            var cell: CategoryCell = self.subcategoryTable.dequeueReusableCellWithIdentifier("subcategoryCell") as! CategoryCell
            cell.category.text = self.category.subcategories[indexPath.row].title
            cell.ownCategory = self.category.subcategories[indexPath.row]
            return cell
        } else if( tableView.tag == questionTableTag){
            var cell: QuestionCell = self.questionTable.dequeueReusableCellWithIdentifier("questionCell") as! QuestionCell
            cell.question.text = self.category.allFAQs[indexPath.row].question
            cell.ownFAQ = self.category.allFAQs[indexPath.row]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toSelf"){
            var faqQuestionController: FAQQuestionController = segue.destinationViewController as! FAQQuestionController
            var categoryCell = sender as! CategoryCell
            faqQuestionController.category = categoryCell.ownCategory
        } else if (segue.identifier == "toAnswer") {
            var questionController: QuestionController = segue.destinationViewController as! QuestionController
            var questionCell = sender as! QuestionCell
            questionController.ownFAQ = questionCell.ownFAQ
        }
    }
}
