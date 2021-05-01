//
//  RulesViewController.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 8/24/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import UIKit

protocol RulesViewControllerDelegate: class {
    func didTapStartCompeting()
}

class RulesViewController: UIViewController, UIScrollViewDelegate {
    
    var feedVC: FeedVC!

    @IBOutlet weak var rulesScrollView: UIScrollView!
    
    @IBOutlet weak var rulePageControl: UIPageControl!
    let rule1 = ["title":"Watch challenge video","image":"watchVideo"]
    let rule2 = ["title":"Start competing by recording and uploading","image":"competitionStart"]
    let rule3 = ["title":"Everyone can vote","image":"vote"]
    let rule4 = ["title":"Whoever has the most votes wins","image":"competitionEnd"]
    let rule5 = ["title":"Winner has to upload a new challenge","image":"trophy"]
    let rule6 = ["title":"Invite your friends","image":"invite_friends"]
    
    var ruleArray = [Dictionary<String, String>]()
    weak var delegate: RulesViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ruleArray = [rule1, rule2, rule3, rule4, rule5, rule6]
        rulesScrollView.isPagingEnabled = true
        rulesScrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(ruleArray.count), height: 250)
        rulesScrollView.showsHorizontalScrollIndicator = false
        rulesScrollView.delegate = self
   
        loadRules()

        // Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        rulePageControl.currentPage = Int(page)
    }
    
    func loadRules(){
        for (index, rule) in ruleArray.enumerated() {
            if let ruleView = Bundle.main.loadNibNamed("Rule", owner: self, options: nil)?.first as? ruleView{
                ruleView.ruleImageView.image = UIImage(named: rule["image"]!)
                ruleView.titleLabel.text = rule["title"]
                
                rulesScrollView.addSubview(ruleView)
                ruleView.frame.size.width = self.view.bounds.size.width
                ruleView.frame.origin.x = CGFloat(index) * self.view.bounds.size.width
            }
        }

    }
    @IBAction func uploadVideoButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.didTapStartCompeting()
        }
    }
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
  
 
 
    

 

}
