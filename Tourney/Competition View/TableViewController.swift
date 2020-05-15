//
//  TableViewController.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import UIKit
import Firebase


class TableViewController: UITableViewController {
    
    struct CellData {
        
        let image: UIImage?
        let message: String?
        let filter: String?
        
    }
    var data = [CellData]()
    var selectedFilter: String!
    var ref: DatabaseReference!
    /// Placeholder for dynamic link tournament id for new usrs
    var dynamicLinkTourneyId: String?
    var dynamicLinkTourneyIdForReturningUsers: String? {
        didSet { // when user is already logge in and opens app via dynamic link
            selectedFilter = dynamicLinkTourneyIdForReturningUsers
            self.performSegue(withIdentifier: "toVideoFeed", sender: nil)
            self.dynamicLinkTourneyIdForReturningUsers = nil
        }
    }
    var firstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [CellData(image: UIImage(named: "BMX_Competition_1"), message: "BMX #1", filter: "BMX_Competition_1"),
                CellData(image: UIImage(named: "BMX_Competition_2"), message: "BMX #2", filter: "BMX_Competition_2")]
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Present tournament if dynamic link is found
        if let dynamicLinkTourneyId = dynamicLinkTourneyId {
            selectedFilter = dynamicLinkTourneyId
            self.performSegue(withIdentifier: "toVideoFeed", sender: nil)
            self.dynamicLinkTourneyId = nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentCell", for: indexPath) as! TournamentCell
        
        let cellData = data[indexPath.row]
        
        cell.backgroundImageView.image = cellData.image
        cell.tournamentTitleLabel.text = cellData.message
        cell.tournamentId = cellData.filter!
        
        return cell
    }
    
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = data[indexPath.row].filter!
        self.performSegue(withIdentifier: "toVideoFeed", sender: nil)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVideoFeed" {
            if let destination = segue.destination as? FeedVC {
                User.sharedInstance.activeFilter = self.selectedFilter
                destination.activeFilter = self.selectedFilter
            }
        }
    }

}
