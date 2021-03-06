//
//  FirstViewController.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 10/24/19.
//  
//
// This is the first view controller a user is presented with after
// downloading our app. The user is presented with two options:
// "Sign up" or "Login"

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignUpLogInVC: UIViewController {
    
    
    @IBOutlet weak var roundedSignUpBtn: UIButton!
    @IBOutlet weak var roundedLoginBtn: UIButton!
    @IBOutlet weak var roundedAnonymousBtn: UIButton!
    
    var dynamicLinkTourneyId: String?
    
    @IBAction func signUpTapped() {
        performSegue(withIdentifier: "showSignUp", sender: nil)
    }
    @IBAction func signInTapped() {
        performSegue(withIdentifier: "showSignIn", sender: nil)
    }
    
    @IBAction func skipTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toOnboardingVC", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roundedSignUpBtn.layer.cornerRadius = 8
        self.roundedLoginBtn.layer.cornerRadius = 8
        self.roundedAnonymousBtn.layer.cornerRadius = 8
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//    
//        // Check if user is already logged in
//        if Auth.auth().currentUser != nil {
//            User.sharedInstance.uid = Auth.auth().currentUser?.uid
//            DatabaseService.loadSingletonData(completionHandler: { (success) in
//                self.performSegue(withIdentifier: "toFeedSegue", sender: nil)
//            })
//        }
//    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUp" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let destinationVC = segue.destination as! SignUpVC
                destinationVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        } else if segue.identifier == "toFeedSegue" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let destinationVC = segue.destination as! TournamentsTableViewController
                destinationVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        } else if segue.identifier == "showSignIn" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let destinationVC = segue.destination as! LoginVC
                destinationVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        } else if segue.identifier == "toOnboardingVC" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let destinationVC = segue.destination as! OnboardingViewController
                destinationVC.dynamicLinkTourneyId = dynamicLinkTourneyId
        }
    }

  
}
}
