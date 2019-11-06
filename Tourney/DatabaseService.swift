//
//  DatabaseService.swift
//  Tourney
//
//  Created by Will Cohen on 7/30/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import Foundation
import Firebase

class DatabaseService {
    
    static func loadSingletonData(completionHandler: @escaping (_ success: Bool) -> Void) {
        let userNodeReference = Database.database().reference().child("users").child(User.sharedInstance.uid);
        userNodeReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]

            User.sharedInstance.profileImageURL = (postDict["profileImageUrl"] as! String);
            User.sharedInstance.username = (postDict["username"] as! String);
            completionHandler(true);
        })
    }
    
}
