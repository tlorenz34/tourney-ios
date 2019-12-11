//
//  ProfileImageView.swift
//  Tourney
//
//  Created by German Espitia on 12/11/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemYellow.cgColor
    }
}
