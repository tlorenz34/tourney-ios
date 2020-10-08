//
//  Tournament.swift
//  Tourney
//
//  Created by German Espitia on 10/8/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation

struct Tournament {
    let name: String
    let id: String
    let featuredImageURL: URL
    let participants: Int
    /// Leader info (may be nil due to no leader due to no votes)
    let leaderId: String?
    let leaderUsername: String?
    let leaderProfileImageURL: URL?
    
    init?(id: String, dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let participants = dictionary["participants"] as? Int,
              let featuredImageURLString = dictionary["featuredImageURL"] as? String,
              let featuredImageURL = URL(string: featuredImageURLString) else {
            return nil
        }
        self.id = id
        self.name = name
        self.participants = participants
        self.featuredImageURL = featuredImageURL
        
        if let leaderId = dictionary["leaderId"] as? String,
           let leaderUsername = dictionary["leaderUsername"] as? String,
           let leaderProfileImageURLString = dictionary["leaderProfileImageURL"] as? String,
           let leaderProfileImageURL = URL(string: leaderProfileImageURLString) {
            self.leaderId = leaderId
            self.leaderUsername = leaderUsername
            self.leaderProfileImageURL = leaderProfileImageURL
        } else {
            self.leaderId = nil
            self.leaderUsername = nil
            self.leaderProfileImageURL = nil
        }
    }
}
