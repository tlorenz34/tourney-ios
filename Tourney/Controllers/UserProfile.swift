//
//  UserProfile.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 6/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//
// View controller for "My Profile" section

import UIKit
import Kingfisher

class UserProfile: UIViewController {

    @IBOutlet weak var userProfileImageView: CircleImage!
    @IBOutlet weak var userNameTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        // unwrap user profile image url
        if let profileImageURL = User.sharedInstance.profileImageURL {
            userProfileImageView.kf.setImage(with: URL(string: profileImageURL))
        }
        // unwrap username
        if let username = User.sharedInstance.username {
            userNameTextField.text = username
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
