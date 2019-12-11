//
//  CustomCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import Foundation
import UIKit

class TournamentCell: UITableViewCell {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var opaqueView: UIView! //
    @IBOutlet var tournamentTitleLabel: UILabel!
    @IBOutlet var leaderPositionImageView: UIImageView!
    @IBOutlet var leaderProfileImageView: UIImageView!
    @IBOutlet var leaderUsernameLabel: UILabel!
    @IBOutlet var participantsLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setup() {
        // set rounded borders
        backgroundImageView.layer.cornerRadius = 15
        opaqueView.layer.cornerRadius = 15
        
        // setup profile image
        leaderProfileImageView.layer.cornerRadius = leaderProfileImageView.frame.width / 2
        leaderProfileImageView.layer.borderColor = UIColor.systemYellow.cgColor
        leaderProfileImageView.layer.borderWidth = 2
        leaderPositionImageView.backgroundColor = UIColor.systemYellow
        leaderPositionImageView.layer.cornerRadius = leaderPositionImageView.frame.width / 2
    }
    
}
