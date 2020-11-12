//
//  TransparentNavigationBar.swift
//  Tourney
//
//  Created by German Espitia on 11/12/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import UIKit

class TransparentNavigationBar: UINavigationBar {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    private func setup() {
        isTranslucent = true
        shadowImage = UIImage()
        setBackgroundImage(UIImage(), for: .default)
    }
    
    
}
