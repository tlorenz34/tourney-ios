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
    @IBOutlet weak var roundedLoginButton: UIButton!

    var userUid: String!

    // MARK: - Actions
    
    @IBAction func loginInTapped(_ sender: Any){
        if let email = loginEmailField.text, let password = loginPasswordField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion:
                {(user, error) in
                    if error == nil{
                        if let user = user {
                            self.userUid = user.uid
                            User.sharedInstance.uid = user.uid
                            DatabaseService.loadSingletonData(completionHandler: { (success) in
                                self.goToFeedVC()
                            })
                        }
                    } else {
                        print("user does not exist yet")
                        self.doesNotExistLabel.textColor = UIColor.red
                        print("USER DOES NOTTTT EXIST")
                        self.goToCreateUserVC()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            User.sharedInstance.uid = KeychainWrapper.standard.string(forKey: "uid")
            DatabaseService.loadSingletonData { (success) in
                self.goToFeedVC()
            }
        }
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



