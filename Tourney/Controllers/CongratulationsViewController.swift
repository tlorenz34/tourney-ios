//
//  CongratulationsViewController.swift
//  
//
//  Created by German Espitia on 11/11/20.
//

import Foundation
import UIKit

class CongratulationsViewController: UIViewController {
    
    override func viewDidLoad() {
        let confettiView = SAConfettiView(frame: view.frame)
        view.addSubview(confettiView)
        confettiView.startConfetti()
    }
}
