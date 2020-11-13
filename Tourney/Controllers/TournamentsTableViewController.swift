//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.


import UIKit
import Firebase
import Kingfisher

/**
 Displays active tournaments.
 */
class TournamentsTableViewController: UITableViewController {
    
    var tournaments: [Tournament] = []
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
        fetchTournaments()
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
        return tournaments.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentCell", for: indexPath) as! TournamentCell
        
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
        
        // add notifiers //
        
        // if user won tournament
        if let parentTournamentWinnerId = tournament.parentTournamentWinnerId,
           let currentUser = Auth.auth().currentUser {
            // if user won and challenge video has not been uploaded
            if parentTournamentWinnerId == currentUser.uid && tournament.featuredVideoURL == nil {
                cell.noticeLabel.isHidden = false
                cell.noticeLabel.text = "You've won!"
            } else {
                cell.noticeLabel.isHidden = true
            }
        }
        // if tournament ended
        else if !tournament.canInteract {
            cell.noticeLabel.isHidden = false
            cell.noticeLabel.text = "Tournament ended"
        }
        // else, hide notifier label
        else {
            cell.noticeLabel.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tournament = tournaments[indexPath.row]

        // if user is winner and challenge video has not been upload, show won VC flow
        if let parentTournamentWinnerId = tournament.parentTournamentWinnerId,
           let currentUser = Auth.auth().currentUser {
            
            if parentTournamentWinnerId == currentUser.uid {
                if tournament.featuredVideoURL == nil {
                    // go to won vc flow
                    presentWinnerFlowStoryboard(tournament: tournament, tournamentsViewController: self)
                } else {
                    // already uploaded featured video
                    performSegue(withIdentifier: "SubmissionsViewController", sender: tournament)
                }
            } else {
                // regular user (not winner)
                performSegue(withIdentifier: "SubmissionsViewController", sender: tournament)
            }
        } else {
            // regular user (not winner)
            performSegue(withIdentifier: "SubmissionsViewController", sender: tournament)
        }
        
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SubmissionsViewController" {
            if let destination = segue.destination as? FeedVC {
                let tournament = sender as! Tournament
                destination.tournament = tournament
            }
        }
    }
    
    /// Fetch active and won tournaments
    private func fetchTournaments() {
        let tournamentsManager = TournamentManager()
        tournamentsManager.fetchActiveTournaments { (_tournaments) in
            if let _tournaments = _tournaments {
                self.addTournamentsIfUnique(_tournaments: _tournaments)
                self.tableView.reloadData()
            }
        }
        tournamentsManager.fetchWonTournaments { (_tournaments) in
            if let _tournaments = _tournaments {
                self.addTournamentsIfUnique(_tournaments: _tournaments)
                self.tableView.reloadData()
            }
        }
    }
    /// Add tournaments to `tournaments` when array does not already contain it.
    private func addTournamentsIfUnique(_tournaments: [Tournament]) {
        for tournament in _tournaments {
            if !tournaments.contains(where: {
                $0.id == tournament.id
            }) {
                tournaments.append(tournament)
            }
        }
    }
}
