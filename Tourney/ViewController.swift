//
//  ViewController.swift
//  Tourney
//
//  Created by Will Cohen on 7/29/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ViewController: UIViewController, UITextFieldDelegate {
    
   // @IBOutlet weak var emailField: UITextField!
    //@IBOutlet weak var passwordField: UITextField!
    var userUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // emailField.delegate = self
       // passwordField.delegate = self
        
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return (true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUp"{
            if let destination = segue.destination as? UserVC{
                if userUid != nil{
                    destination.userUid = userUid
                }
                if emailField.text != nil {
                    destination.emailField = emailField.text
                }
                if passwordField.text != nil {
                    destination.passwordField = passwordField.text
                }
                
            }
            
        }
    }
    
    func goToCreateUserVC(){
        performSegue(withIdentifier: "SignUp", sender: nil)
    }
    func goToFeedVC(){
        performSegue(withIdentifier: "toFeedSegue", sender: nil)
    }
    
    @IBAction func signInTapped(_ sender: Any){
        if let email = emailField.text, let password = passwordField.text {
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
                        self.goToCreateUserVC()
                    }
                    
            })
            
        }
    }
    
    
}



