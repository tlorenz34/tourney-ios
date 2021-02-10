//
//  TabCollectionViewCell.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit

class TabCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = containerView.frame.height / 2
            containerView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ? .black : UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
            titleLabel.textColor = isSelected ? .white : .black
        }
    }
    
    override func layoutSubviews() {
        containerView.layer.cornerRadius = containerView.frame.height / 2
    }
    
}
