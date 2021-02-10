//
//  Tournament.swift
//  Tourney
//
//  Created by German Espitia on 10/8/20.
//  Copyright © 2020 Thaddeus Lorenz. All rights reserved.
//

import Foundation
import Firebase

struct Tournament {
    let createdAt: Date
    var name: String
    let id: String
    let featuredImageURL: URL
    /// Flag to determine whether the voting/submission phase has ended.
    var canInteract: Bool
    let participants: Int
    /// Leader info (may be nil due to no leader due to no votes)
    let leaderId: String?
    let leaderUsername: String?
    let leaderProfileImageURL: URL?
    let parentTournamentId: String?
    let parentTournamentWinnerId: String?
    var featuredVideoURL: URL?
    var active: Bool
    var challengeType: String
    let channel: String?
    
    /// Dictionary representation of object
    var dictionary: [String : Any] {
        var dict: [String : Any] = [
            "name": name,
            "featuredImageURL": featuredImageURL.absoluteString,
            "canInteract": canInteract,
            "participants": participants,
            "active": active,
            "channel": channel ?? "",
        ]
        
        if let leaderId = leaderId {
            dict["leaderId"] = leaderId
        } else {
            dict["leaderId"] = ""
        }
        if let leaderUsername = leaderUsername {
            dict["leaderUsername"] = leaderUsername
        } else {
            dict["leaderUsername"] = ""
        }
        if let leaderProfileImageURL = leaderProfileImageURL {
            dict["leaderProfileImageURL"] = leaderProfileImageURL.absoluteString
        } else {
            dict["leaderProfileImageURL"] = ""
        }
        if let parentTournamentId = parentTournamentId {
            dict["parentTournamentId"] = parentTournamentId
        } else {
            dict["parentTournamentId"] = ""
        }
        if let parentTournamentWinnerId = parentTournamentWinnerId {
            dict["parentTournamentWinnerId"] = parentTournamentWinnerId
        } else {
            dict["parentTournamentWinnerId"] = ""
        }
        if let featuredVideoURL = featuredVideoURL {
            dict["featuredVideoURL"] = featuredVideoURL.absoluteString
        } else {
            dict["featuredVideoURL"] = ""
        }
        dict["challengeType"] = challengeType
        
        return dict
    }
    
    init?(id: String, dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let createdAtTimestamp = dictionary["createdAt"] as? Timestamp,
              let participants = dictionary["participants"] as? Int,
              let featuredImageURLString = dictionary["featuredImageURL"] as? String,
              let featuredImageURL = URL(string: featuredImageURLString),
              let canInteract = dictionary["canInteract"] as? Bool,
              let active = dictionary["active"] as? Bool else {
            return nil
        }
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtTimestamp.seconds))
        self.id = id
        self.name = name
        self.participants = participants
        self.featuredImageURL = featuredImageURL
        self.canInteract = canInteract
        self.active = active
        self.challengeType = (dictionary["challengeType"] as? String) ?? ChallengeType.public.rawValue
        self.channel = dictionary["channel"] as? String
        
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
        if let featuredVideoURLString = dictionary["featuredVideoURL"] as? String,
           let featuredVideoURL = URL(string: featuredVideoURLString) {
            self.featuredVideoURL = featuredVideoURL
        } else {
            self.featuredVideoURL = nil
        }
    }
}
