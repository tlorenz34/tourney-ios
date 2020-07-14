//
//  User.swift
//  goldcoastleague
//
//  Created by Will Cohen on 7/17/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

// When a user signs up, they create a username, profile picture
import Foundation
import Firebase

final class User {
    static let sharedInstance = User()
    private init() { }
    
    var uid: String!
    var username: String?
    var profileImageURL: String?
    var activeFilter: String!
    /// Holds the one vote allowed per competition in a dictionary: [competitionId : postId]
    var votes: [String : String]?
    
}


/**
Class to manage networking aspects of the User model
*/
class UserManager {
    
    var uid: String
    var userRef: DatabaseReference {
        Database.database().reference().child("users").child(uid)
    }
    
    init?() {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        self.uid = currentUser.uid
    }
    /**
     Remove vote from competition
     */
    public func removeVoteFromCompetition(competitionId: String) {
        userRef.child("votes").child(competitionId).removeValue()
    }
    /**
     Add vote to a post within a competition
     */
    public func addVote(competitionId: String, postId: String) {
        userRef.child("votes").setValue([competitionId : postId])
    }
    /**
     Get `votes` property for user
     */
    public func getVotes(completion: @escaping ([String : String]?) -> Void) {
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String : Any],
                let votes =  value["votes"] as? [String : String] {
                completion(votes)
            } else {
                completion(nil)
            }
        }
    }
}
