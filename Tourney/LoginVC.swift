//
//  LoginVC.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 10/23/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftKeychainWrapper



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
