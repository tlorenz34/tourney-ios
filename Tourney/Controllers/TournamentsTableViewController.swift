//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.


import UIKit
import Firebase
import Kingfisher
import DateToolsSwift

/**
 Displays active tournaments.
 */
class TournamentsTableViewController: UITableViewController {
    
    var tournaments: [Tournament] = []
    /// Dynamic link to handle non-logged in or app-closed users (get's handled after tournaments are loaded)
    var dynamicLinkTourneyId: String?
    /// Dynamic link to handle already logged in user who opens app via dynamic link
    var dynamicLinkTourneyIdForReturningUsers: String? {
        didSet {
            if let dynamicLink = dynamicLinkTourneyIdForReturningUsers {
                presentTournamentViaDynamicLink(dynamicLinkTournamentId: dynamicLink)
            }
        }
    }
    var firstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchTournaments()
    }
    
    // MARK: Table Data Source & Delegate

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
        cell.timeLeftLabel.text = timeLeftString(tournament: tournament)
        
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
        
        // default to no notifier
        cell.noticeLabel.isHidden = true
        
        // if user won tournament
        if let parentTournamentWinnerId = tournament.parentTournamentWinnerId,
           let currentUser = Auth.auth().currentUser {
            // if user won and challenge video has not been uploaded
            if parentTournamentWinnerId == currentUser.uid && tournament.featuredVideoURL == nil {
                cell.noticeLabel.isHidden = false
                cell.noticeLabel.text = "Upload challenge!"
            } else {
                cell.noticeLabel.isHidden = true
            }
        }
        if let leaderId = tournament.leaderId,
           let currentUser = Auth.auth().currentUser {
            // if tournament ended and user won it
            if !tournament.canInteract && leaderId == currentUser.uid {
                cell.noticeLabel.isHidden = false
                cell.noticeLabel.text = "You are the winner!"
            }
            // if tournament ended and user did not win it
            else if !tournament.canInteract && leaderId != currentUser.uid {
                cell.noticeLabel.isHidden = false
                cell.noticeLabel.text = "Tournament ended"
            }
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
    
    // MARK: Helpers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SubmissionsViewController" {
            if let destination = segue.destination as? FeedVC {
                let tournament = sender as! Tournament
                destination.tournament = tournament
            }
        }
    }
    
    /// Parse string for time left for tournament
    private func timeLeftString(tournament: Tournament) -> String {
        
        // calculate time left
        let daysLeft = Date().days(from: tournament.createdAt)
        
        if daysLeft == 0 {
            
            // if 0 days left, try using hours
            let hoursLeft = Date().hours(from: tournament.createdAt)
            if hoursLeft > 0 {
                return "⏳ \(hoursLeft) hours left"
            } else {
                return "--"
            }
        } else {
            return "⏳ \(daysLeft) days left"
        }
    }
    
    /// Fetch active and won tournaments
    private func fetchTournaments() {
        
        // clear out tournaments
        tournaments = []
        // fetch active
        let tournamentsManager = TournamentManager()
        tournamentsManager.fetchActiveTournaments { (_tournaments) in
            if let _tournaments = _tournaments {
                self.addTournamentsIfUnique(_tournaments: _tournaments)
                self.tableView.reloadData()
                // check if dynamic link is available to be passed
                if let dynamicLink = self.dynamicLinkTourneyId {
                    self.presentTournamentViaDynamicLink(dynamicLinkTournamentId: dynamicLink)
                }
            }
        }
        // fetch won
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
    /// Present tournament given dynamic link
    func presentTournamentViaDynamicLink(dynamicLinkTournamentId: String) {
        // Present tournament if dynamic link is found
        if let tournament = tournaments.first(where: { $0.id == dynamicLinkTournamentId }) {
            performSegue(withIdentifier: "SubmissionsViewController", sender: tournament)
        }
        // reset dynamic link property
        dynamicLinkTourneyId = nil
    }
}
