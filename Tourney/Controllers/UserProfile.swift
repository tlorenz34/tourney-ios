//
//  UserProfile.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 6/29/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//
// View controller for "My Profile" section

import UIKit
import Kingfisher

class UserProfile: UIViewController {
    
    @IBOutlet weak var userProfileImageView: UIImageView! {
        didSet {
            userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height / 2
            userProfileImageView.layer.masksToBounds = true
            userProfileImageView.layer.borderColor = UIColor.black.cgColor
            userProfileImageView.layer.borderWidth = 3
        }
    }
    
    @IBOutlet weak var winsCountLabel: UILabel!
    @IBOutlet weak var participatedCountLabel: UILabel!
    @IBOutlet weak var votesCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        title = User.sharedInstance.username ?? "-"
        
        // unwrap user profile image url
        if let profileImageURL = User.sharedInstance.profileImageURL {
            userProfileImageView.kf.setImage(with: URL(string: profileImageURL))
        }
        
        UserManager()?.getVotes { votes in
            guard let votes = votes else { return }
            self.votesCountLabel.text = "\(votes.count)"
        }
        
        TournamentManager().fetchPastWonTournaments { tournaments in
            guard let tournaments = tournaments else { return }
            self.winsCountLabel.text = "\(tournaments.count)"
        }
        
        SubmissionManager().fetchSubmissionsOfUser { submissions in
            guard let submissions = submissions else { return }
            self.participatedCountLabel.text = "\( Set(submissions.map({$0.tournamentId})).count )"
        }
    }

}
