//
//  InitialViewController.swift
//  Tourney
//
//  Created by admin on 12/9/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import UIKit
import Firebase

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		if Auth.auth().currentUser != nil {
			User.sharedInstance.uid = Auth.auth().currentUser?.uid
			DatabaseService.loadSingletonData(completionHandler: { (success) in
				NotificationCenter.default.post(name: .signedInNotification, object: nil)
			})
//			replaceVCWith(storyboard: "Main", identifier: "CategoriesTableViewController")
		} else {
			NotificationCenter.default.post(name: .signOutNotification, object: nil)
		}
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
