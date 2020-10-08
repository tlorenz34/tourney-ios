//
//  CustomCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

//
// This class makes up each competition/tournament that is created.
// This class represents what you see after you have logged into the app
// and are presented with various competitions that includes the name, # of participants,
// and the current leader (user with the most views)

import Foundation
import UIKit
import Firebase

class TournamentCell: UITableViewCell {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var opaqueView: UIView! //
    @IBOutlet var tournamentTitleLabel: UILabel!
    @IBOutlet var leaderDecorationView: CircleView!
    @IBOutlet var leaderProfileImageView: ProfileImageView!
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
    }
    /**
     Sets state of `isHidden` property of UI components that display leader info.
     */
    func hideLeaderUI(_ hide: Bool) {
        leaderDecorationView.isHidden = hide
        leaderUsernameLabel.isHidden = hide
        leaderProfileImageView.isHidden = hide
    }
}
