//
//  TermsAndConditionsViewController.swift
//  Tourney
//
//  Created by admin on 12/9/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import UIKit
import WebKit

class TermsAndConditionsViewController: UIViewController {

	@IBOutlet weak var m_webviewTaC: WKWebView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.loadTermsAndConditions()
    }
	
	func loadTermsAndConditions() {
		let url = URL(string: "https://www.apple.com")!
		m_webviewTaC.load(URLRequest(url: url))
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	@IBAction func btnBackClicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}
