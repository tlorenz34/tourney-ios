//
//  LeaderboardCell.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 3/25/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit
import Kingfisher

class LeaderboardCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var leaderProfileImageView: UIImageView!
    
    @IBOutlet weak var leaderUsernameLabel: UILabel!
    
    @IBOutlet weak var leaderVotesLabel: UILabel!
    
    @IBOutlet weak var leaderVoteBarView: UIView!
    
    @IBOutlet var leaderButton: UIButton!
    
   
    
    func updateUI(position: Int, submission: Submission){
        positionLabel.text = "\(position + 1)."
        leaderProfileImageView.kf.setImage(with: submission.creatorProfileImageURL)
        leaderUsernameLabel.text = submission.creatorUsername
        leaderVotesLabel.text = "\(submission.votes) votes"
        leaderButton.tag = position
        
        //thumbnailImageView.kf.setImage(with: submission.thumbnailURL)
    }
    @IBOutlet weak var roundedCellView: UIView! {
        didSet {
            roundedCellView.layer.cornerRadius = 20
            roundedCellView.layer.masksToBounds = true
        }
    }


}
