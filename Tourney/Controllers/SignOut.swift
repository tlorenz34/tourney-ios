//
//  SignOut.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 6/30/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class SignOut: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func SignOut (_sender: AnyObject){
        print("presssed")
        try! Auth.auth().signOut()
        
        KeychainWrapper.standard.removeObject(forKey: "uid")
        self.performSegue(withIdentifier: "signedOut", sender: nil)
        
    }
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }

    

}
