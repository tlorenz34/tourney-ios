//
//  TournamentsViewController.swift
//  Tourney
//
//  Created by Thaddeus Lorenz on 4/6/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import DateToolsSwift

class TournamentsViewController: UIViewController {

    // Live / Finished
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var startingSoonLabel: UILabel!
    
    var judge: User?
    var allTournaments = [Tournament]()
    var liveTournaments = [Tournament]()
    var finishedTournaments = [Tournament]()
    
    var userDidSelectLive: Bool {
        return segmentController.selectedSegmentIndex == 0
    }
    
    var channelId: String?
    var tournaments: [Tournament] = [] {
        didSet {
            for tournament in tournaments {
                fetchSubmissionsForTournament(tournament: tournament)
            }
        }
    }

    var tournamentsSubmissions: [Tournament:[Submission]] = [:]
    var tournamentLength: Int?
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
        fetchTournaments()
        
        navigationItem.title = "All Contests"
        self.startingSoonLabel.isHidden = true
       
        
    }
    
    @IBAction func segmentControlDidChange(_ sender: UISegmentedControl) {
        mainTableView.reloadData()
        
     
        mainTableView.isHidden = userDidSelectLive && liveTournaments.isEmpty
        startingSoonLabel.isHidden = !mainTableView.isHidden
        
    }
    
    // MARK: Table Data Source & Delegate

    
  
    
    
    
    
    
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
                
        guard let tournamentLength = tournamentLength else {
            return "--"
        }
        
        // calculate time left
        let hoursLeft = tournament.createdAt.add(tournamentLength.days).hoursUntil
            
        if hoursLeft <= 0 {
            return "--"
        } else if hoursLeft < 24 {
            return "\(hoursLeft) hours left"
        } else {
            return "\(Int(ceil(Double(hoursLeft)/24.0))) days left"
        }
    }
    
    private func fetchSubmissionsForTournament(tournament: Tournament) {
        guard tournamentsSubmissions[tournament].isNilOrEmpty else { return }
        
        SubmissionManager().fetchSubmissionsForTournament(tournamentId: tournament.id) { (submissions) in
            if let submissions = submissions {
                self.tournamentsSubmissions[tournament] = submissions
                self.mainTableView.reloadData()
            }
        }
    }
    
    
    private func fetchTournaments() {
        guard let channelId = channelId else {
            return
        }
        
        let tournamentsManager = TournamentManager()
        tournamentsManager.fetchTournaments(channelId: channelId) { (tournaments) in
            
            guard let tournaments = tournaments else {
                self.mainTableView.isHidden = self.userDidSelectLive && self.liveTournaments.isEmpty
                self.startingSoonLabel.isHidden = !self.mainTableView.isHidden
                return
            }
            
            
            self.allTournaments = tournaments
           
//            self.liveTournaments = tournaments.filter {
//                $0.active && $0.canInteract
//                // true && true ==> true
//                // true && false  ==> false
//                // false && true  ==> false
//                // false && false  ==> false
//            }
            
            self.liveTournaments = tournaments.filter{ $0.active && $0.canInteract}
            
           
            
            self.finishedTournaments = tournaments.filter { $0.active && !$0.canInteract }
           
            // fetch tournament length data
            
            AdminManager().fetchTournamentLengthDays { (length) in
                if let length = length {
                    self.tournamentLength = length
                    
                    
                    if let liveTournament = self.liveTournaments.first, let judgeId = liveTournament.judgeId{
                        let userManager = UserManager()
                        userManager?.getUser(userId: judgeId, completion: { (judge) in
                            self.judge = judge
                        
                            self.mainTableView.reloadData()
                            self.mainTableView.isHidden = self.userDidSelectLive && self.liveTournaments.isEmpty
                            self.startingSoonLabel.isHidden = !self.mainTableView.isHidden
                        })
                        
                    } else{
                        self.mainTableView.reloadData()
                        self.mainTableView.isHidden = self.userDidSelectLive && self.liveTournaments.isEmpty
                        self.startingSoonLabel.isHidden = !self.mainTableView.isHidden
                    }
                    
                }
            }
            
            
//            if let _tournaments = _tournaments {
//                self.addTournamentsIfUnique(_tournaments: _tournaments)
//                self.mainTableView.reloadData()
//                // check if dynamic link is available to be passed
//                if let dynamicLink = self.dynamicLinkTourneyId {
//                    self.presentTournamentViaDynamicLink(dynamicLinkTournamentId: dynamicLink)
//                }
//            }
        }
    }
    
    
    
//    /// Fetch active and won tournaments
//    private func fetchTournaments() {
//
//        // clear out tournaments
//        tournaments = []
//        // fetch active
//        let tournamentsManager = TournamentManager()
//        tournamentsManager.fetchActiveTournaments(channelId: channelId ?? "") { (_tournaments) in
//            if let _tournaments = _tournaments {
//                self.addTournamentsIfUnique(_tournaments: _tournaments)
//                self.mainTableView.reloadData()
//                // check if dynamic link is available to be passed
//                if let dynamicLink = self.dynamicLinkTourneyId {
//                    self.presentTournamentViaDynamicLink(dynamicLinkTournamentId: dynamicLink)
//                }
//            }
//        }
//        // fetch won
//        tournamentsManager.fetchWonTournaments(channelId: channelId ?? "") { (_tournaments) in
//            if let _tournaments = _tournaments {
//                self.addTournamentsIfUnique(_tournaments: _tournaments)
//                self.mainTableView.reloadData()
//            }
//        }
//
//        // fetch tournament length data
//        let adminManager = AdminManager()
//        adminManager.fetchTournamentLengthDays { (length) in
//            if let length = length {
//                self.tournamentLength = length
//                self.mainTableView.reloadData()
//            }
//        }
//    }
//    /// Add tournaments to `tournaments` when array does not already contain it.
//    private func addTournamentsIfUnique(_tournaments: [Tournament]) {
//        for tournament in _tournaments {
//            if !tournaments.contains(where: {
//                $0.id == tournament.id
//            }) {
//                tournaments.append(tournament)
//            }
//        }
//    }
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

// unrecognize selector sent to instance 0x2305923502
// binary - 0 /1
// decimal - 0-9
// hexidecimal 0-9/A-F
extension TournamentsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userDidSelectLive {
            return liveTournaments.isEmpty ? 0 : liveTournaments.count + 1
        } else{
            return finishedTournaments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create and return the judge cell if user selects live and element is last in the list
        if userDidSelectLive && indexPath.row == liveTournaments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JudgeCell", for: indexPath) as! JudgeCell
            cell.updateUI(judge: judge)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentCell", for: indexPath) as! TournamentCell

        let tournament = userDidSelectLive ? liveTournaments[indexPath.row] : finishedTournaments[indexPath.row]

        cell.backgroundImageView.kf.setImage(with: tournament.featuredImageURL)
        cell.tournamentTitleLabel.text = tournament.name
        cell.participantsLabel.text = "\(tournament.participants)"
        cell.timeLeftLabel.text = timeLeftString(tournament: tournament)
        cell.typeLabel.text = "\(tournament.challengeType) Challenge"

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
                cell.noticeLabel.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
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
                cell.noticeLabel.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            }
            // if tournament ended and user did not win it
            else if !tournament.canInteract && leaderId != currentUser.uid {
                cell.noticeLabel.isHidden = false
                cell.noticeLabel.text = "Tournament ended"
                cell.noticeLabel.backgroundColor = #colorLiteral(red: 0.9329768479, green: 0.1309130161, blue: 0.1541970009, alpha: 1)
            }
        }

        let viewerCount = tournamentsSubmissions[tournament]?.reduce(into: 0, { result, submission in
            result += submission.views
        })
        if let viewerCount = viewerCount {
            if viewerCount > 1 {
                cell.viewersLabel.text = "\(viewerCount) viewers"
            } else {
                cell.viewersLabel.text = "\(viewerCount) viewer"
            }
            cell.viewersLabel.isHidden = false
            cell.viewersImageView.isHidden = false
        } else {
            cell.viewersLabel.isHidden = true
            cell.viewersImageView.isHidden = true
        }

        return cell
    }
    
}


extension TournamentsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return userDidSelectLive && liveTournaments.count == indexPath.row ? 100 : 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // If user selects a judge, return
        if userDidSelectLive && indexPath.row == liveTournaments.count{
            return
        }
        
        // livesTournaments[1]
        let tournament = userDidSelectLive ? liveTournaments[indexPath.row] : finishedTournaments[indexPath.row]
//        let tournament = tournaments[indexPath.row]

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
}

