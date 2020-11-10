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
    /// Flag to determine whether the voting/submission phase has ended.
    let canInteract: Bool
    let participants: Int
    /// Leader info (may be nil due to no leader due to no votes)
    let leaderId: String?
    let leaderUsername: String?
    let leaderProfileImageURL: URL?
    let parentTournamentId: String?
    let parentTournamentWinnerId: String?
    let featuredVideoURL: URL?
    
    init?(id: String, dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let participants = dictionary["participants"] as? Int,
              let featuredImageURLString = dictionary["featuredImageURL"] as? String,
              let featuredImageURL = URL(string: featuredImageURLString),
              let canInteract = dictionary["canInteract"] as? Bool else {
            return nil
        }
        self.id = id
        self.name = name
        self.participants = participants
        self.featuredImageURL = featuredImageURL
        self.canInteract = canInteract
        
        // leader info
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
        
        // parent tournament info
        if let parentTournamentId = dictionary["parentTournamentId"] as? String,
           let parentTournamentWinnerId = dictionary["parentTournamentWinnerId"] as? String {
            self.parentTournamentId = parentTournamentId
            self.parentTournamentWinnerId = parentTournamentWinnerId
        } else {
            self.parentTournamentId = nil
            self.parentTournamentWinnerId = nil
        }
        
        // featured
        if let featuredVideoURLString = dictionary["featuredVideoURLString"] as? String,
           let featuredVideoURL = URL(string: featuredVideoURLString) {
            self.featuredVideoURL = featuredVideoURL
        } else {
            self.featuredVideoURL = nil
        }
    }
}
