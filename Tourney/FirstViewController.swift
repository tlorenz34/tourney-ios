//
//  FirstViewController.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 10/24/19.
//  
//

import UIKit

class FirstViewController: UIViewController {
    
    
    @IBOutlet weak var roundedSignUpBtn: UIButton!
    
    @IBOutlet weak var roundedLoginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roundedSignUpBtn.layer.cornerRadius = 8
        self.roundedLoginBtn.layer.cornerRadius = 8

        
    }
    

  
}
