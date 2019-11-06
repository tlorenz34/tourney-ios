//
//  UserProfile.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 6/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Kingfisher

class UserProfile: UIViewController {

    @IBOutlet weak var userProfileImageView: CircleImage!
    @IBOutlet weak var userNameTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        userProfileImageView.kf.setImage(with: URL(string: User.sharedInstance.profileImageURL))
        userNameTextField.text = User.sharedInstance.username
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
