//
//  LoginVC.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 10/23/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var doesNotExistLabel: UILabel!
    @IBOutlet weak var roundedLoginButton: LoadingUIButton!
    
    @IBAction func createAccountTapped() {
        goToCreateUserVC()
    }
    
    var dynamicLinkTourneyId: String?
    var userUid: String!

    // MARK: - Actions
    
    @IBAction func loginInTapped(_ sender: Any){
        roundedLoginButton.showLoading()
        if let email = loginEmailField.text, let password = loginPasswordField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion:
                {(user, error) in
                    if error == nil{
                        if let user = user {
                            self.userUid = user.user.uid
                            User.sharedInstance.uid = user.user.uid
                            DatabaseService.loadSingletonData(completionHandler: { (success) in
                                self.roundedLoginButton.hideLoading()
                                self.goToFeedVC()
                            })
                        }
                    } else {
                        self.roundedLoginButton.hideLoading()
                        print("user does not exist yet")
                        self.doesNotExistLabel.textColor = UIColor.red
                    }
                    
            })
            
        }
    }
    
    @IBAction func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginEmailField.delegate = self
        loginPasswordField.delegate = self
        self.roundedLoginButton.layer.cornerRadius = 7
        
        // Do any additional setup after loading the view.
        print(dynamicLinkTourneyId)
    }

    // MARK: - Helpers

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // used to be "toSignUp"
        if segue.identifier == "toSignUp"{
            
            if let destination = segue.destination as? UserVC{
                if userUid != nil{
                    destination.userUid = userUid
                }
                if loginEmailField.text != nil {
                    destination.emailField = loginEmailField.text
                }
                if loginPasswordField.text != nil {
                    destination.passwordField = loginPasswordField.text
                }
                
            }
            
        } else if segue.identifier == "toFeedVC" {
            if let dynamicLinkTourneyId = dynamicLinkTourneyId {
                let feedVC = segue.destination as! TableViewController
                feedVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        }
    }
    
    func goToCreateUserVC(){
        performSegue(withIdentifier: "toSignUp", sender: nil)
    }

    func goToFeedVC(){
        performSegue(withIdentifier: "toFeedVC", sender: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return (true)
    }

    
}



