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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [CellData(image: UIImage(named: "BMX_Competition_1"), message: "BMX #1", filter: "BMX_Competition_1"),
                CellData(image: UIImage(named: "BMX_Competition_2"), message: "BMX #2", filter: "BMX_Competition_2")]
    }
    
    func getTournamentData(eventId: String, completion: @escaping (_ winnerPost: Post?, _ participants: Int) -> Void) {
        
        ref = Database.database().reference()
        ref.child("posts")
            .queryOrdered(byChild: "eventID")
            .queryEqual(toValue: eventId)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                    
            var tournamentPosts: [Post] = []
            var winningPost: Post?
            var participants: Int = 0
            
            // query retrieves Posts. Children would be subset of Posts with eventId.
            if let postSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                // Parse posts into array
                for postSnapshot in postSnapshots {
                    if let postDict = postSnapshot.value as? Dictionary<String, AnyObject>{
                        let key = postSnapshot.key
                        let post = Post(postKey: key, postData: postDict)
                        tournamentPosts.append(post)
                    }
                }
                // sort torunament posts by views
                tournamentPosts = tournamentPosts.sorted(by: { $0.views > $1.views } )
                // set winner
                if let winnerPost = tournamentPosts.first {
                    winningPost = winnerPost
                }
                // count participants
                participants = tournamentPosts.count
                
                completion(winningPost, participants)
            }

          }) { (error) in
            print(error.localizedDescription)
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
