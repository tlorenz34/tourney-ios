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
    
    var dynamicLinkTourneyId: String?
    
    @IBAction func signUpTapped() {
        performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roundedSignUpBtn.layer.cornerRadius = 8
        self.roundedLoginBtn.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        // Check if user is already logged in
        if Auth.auth().currentUser != nil {        
            User.sharedInstance.uid = Auth.auth().currentUser?.uid
            DatabaseService.loadSingletonData(completionHandler: { (success) in
                self.performSegue(withIdentifier: "toFeedSegue", sender: nil)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUp" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let destinationVC = segue.destination as! UserVC
                destinationVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        } else if segue.identifier == "toFeedSegue" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let destinationVC = segue.destination as! TableViewController
                destinationVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        }
    }

  
}
