//
//  ProfileImageView.swift
//  Tourney
//
//  Created by German Espitia on 12/11/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit

/**
 UIImageView subclass to maintain consistency across all profile images.
 */
class ProfileImageView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 3
        layer.borderColor = UIColor.systemYellow.cgColor
    }
}
