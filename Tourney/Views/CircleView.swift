//
//  CircleView.swift
//  Tourney
//
//  Created by German Espitia on 12/12/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit

/**
 Class to draw a circle view.
 */
class CircleView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.width / 2
    }

}
