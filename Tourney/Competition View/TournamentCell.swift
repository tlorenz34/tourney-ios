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
    @IBOutlet var tournamentTitleLabel: UILabel!
    @IBOutlet var leaderProfileImageView: UIImageView!
    @IBOutlet var leaderUsernameLabel: UILabel!
    @IBOutlet var participantsLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
