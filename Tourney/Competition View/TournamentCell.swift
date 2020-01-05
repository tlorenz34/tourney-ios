//
//  CustomCell.swift
//  goldcoastleague
//
//  Created by Thaddeus Lorenz on 7/3/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentCell: UITableViewCell {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var opaqueView: UIView! //
    @IBOutlet var tournamentTitleLabel: UILabel!
    @IBOutlet var leaderPositionImageView: ProfileImageView!
    @IBOutlet var leaderProfileImageView: ProfileImageView!
    @IBOutlet var leaderUsernameLabel: UILabel!
    @IBOutlet var participantsLabel: UILabel!
    
    /**
     Tournament ID (also eventID in database) that when set will fetch tournament data (leader) and update the corresponding UI.
     */
    var tournamentId: String? {
        didSet {
            getTournamentData(eventId: self.tournamentId!) { (winnerPost: Post?, participants: Int) in
                // check if there is a winner
                if let winnerPost = winnerPost {
                    self.leaderUsernameLabel.text = winnerPost.username
                    self.participantsLabel.text = "\(participants) participants"
                    self.downloadImage(from: URL(string: winnerPost.userImg)!, imageView: self.leaderProfileImageView)
                }
            }
        }
    }

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
     Fetch the current winning submission (`Post`) and number of participants given the `eventID` of a tournament.
     */
    func getTournamentData(eventId: String, completion: @escaping (_ winnerPost: Post?, _ participants: Int) -> Void) {
        let ref = Database.database().reference()
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
                participants = self.uniquePosts(posts: tournamentPosts)
                
                completion(winningPost, participants)
            }

          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func downloadImage(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /// Counts the number of unique `Post` of a `Post` array based on the `username` field of each `Post`.
    func uniquePosts(posts: [Post]) -> Int {
        var uniquePosts: [Post] = []
        for post in posts {
            print(post.username)
            if !uniquePosts.contains(where: {$0.username == post.username}) {
                uniquePosts.append(post)
            }
        }
        print("END")
        return uniquePosts.count
    }
}
