//
//  ChannelTableViewCell.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.layer.cornerRadius = 20
            backgroundImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var opaqueView: UIView! {
        didSet {
            opaqueView.layer.cornerRadius = 20
            opaqueView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var bannerView: UIView! {
        didSet {
            bannerView.layer.cornerRadius = bannerView.frame.height / 2
            bannerView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var dotView: UIView! {
        didSet {
            dotView.layer.cornerRadius = dotView.frame.height / 2
            dotView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.dotView.backgroundColor = .green
            }, completion: nil)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func layoutSubviews() {
        bannerView.layer.cornerRadius = bannerView.frame.height / 2
        dotView.layer.cornerRadius = dotView.frame.height / 2
    }
    
}
