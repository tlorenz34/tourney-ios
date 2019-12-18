//
//  FirstViewController.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 10/24/19.
//  
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var roundedSignUpBtn: UIButton!
    
    @IBOutlet weak var roundedLoginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roundedSignUpBtn.layer.cornerRadius = 8
        self.roundedLoginBtn.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if user is already logged in
        if Auth.auth().currentUser != nil {
            
            performSegue(withIdentifier: "toFeedSegue", sender: nil)
            
//            User.sharedInstance.uid = Auth.auth().currentUser?.uid
//            DatabaseService.loadSingletonData(completionHandler: { (success) in
//                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                let CategoriesTableViewController = storyBoard.instantiateViewController(withIdentifier: "CategoriesTableViewController")
//                self.present(CategoriesTableViewController, animated: true, completion: nil)
//            })
        }
    }
    

  
}
