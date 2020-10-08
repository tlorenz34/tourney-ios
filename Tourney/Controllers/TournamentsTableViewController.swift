//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//
// This class is when you want to create a new TournamentCell.
// Whenever I want to add or modify a competition, I have to manually adjust
// this class in order to change the name/cover photo

import UIKit
import Firebase
import Kingfisher

class TournamentsTableViewController: UITableViewController {
    
    var tournaments: [Tournament]?
    /// Placeholder for dynamic link tournament id for new usrs
    var dynamicLinkTourneyId: String?
    var dynamicLinkTourneyIdForReturningUsers: String? {
        didSet { // when user is already logge in and opens app via dynamic link
            // PASS DYNAMIC LINK TO VIDEO FEED
            // in prepForSegue, set FeedVC.activeFilter to the tournament id
            // change activeFilter property name to a more accurate representation of what it means
            // RESET DYNAMIC LINK TO NIL
        }
    }
    var firstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TournamentManager().fetchActiveTournaments { (tournaments) in
            if let tournaments = tournaments {
                self.tournaments = tournaments
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Present tournament if dynamic link is found
        if let dynamicLinkTourneyId = dynamicLinkTourneyId {
            // PASS DYNAMIC LINK TO VIDEO FEED
            // in prepForSegue, set FeedVC.activeFilter to the tournament id
            // change activeFilter property name to a more accurate representation of what it means
            // RESET DYNAMIC LINK TO NIL
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tournaments = tournaments else {
            return 0
        }
        return tournaments.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentCell", for: indexPath) as! TournamentCell
        guard let tournaments = tournaments else {
            return UITableViewCell()
        }
        
        let tournament = tournaments[indexPath.row]
        
        cell.backgroundImageView.kf.setImage(with: tournament.featuredImageURL)
        cell.tournamentTitleLabel.text = tournament.name
        cell.participantsLabel.text = "\(tournament.participants)"
        
        // check if there is a leader
        if let _ = tournament.leaderId,
           let leaderUsername = tournament.leaderUsername,
           let leaderProfileImageURL = tournament.leaderProfileImageURL {
            
            cell.hideLeaderUI(false)
            cell.leaderUsernameLabel.text = leaderUsername
            cell.leaderProfileImageView.kf.setImage(with: leaderProfileImageURL)
            
        } else {
            // if no leader, hide leader UI from tournament cell
            cell.hideLeaderUI(true)
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tournaments = tournaments else { return }
        let tournament = tournaments[indexPath.row]
        performSegue(withIdentifier: "toVideoFeed", sender: tournament.id)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoFeed" {
            if let destination = segue.destination as? FeedVC {
                let tournamentId = sender as! String
                destination.activeFilter = tournamentId
            }
        }
    }

}
