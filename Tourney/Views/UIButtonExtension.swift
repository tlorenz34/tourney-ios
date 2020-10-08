//
//  UIButtonExtension.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 6/6/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    
    func pulsate(){
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 8.0
        pulse.fromValue = 0.95
        pulse.toValue = 1.2
        pulse.autoreverses = true
        pulse.repeatCount = 1000000
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
}
