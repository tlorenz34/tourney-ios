//
//  Submission.swift
//  Tourney
//
//  Created by German Espitia on 10/8/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation
import Firebase

struct Submission {
    let id: String
    let creatorId: String
    let tournamentId: String
    let creatorProfileImageURL: URL
    let creatorUsername: String
    let thumbnailURL: URL
    let videoURL: URL
    let views: Int
    let votes: Int
    let judgeVotes: Int?
    
    init?(id: String, dictionary: [String : Any]) {
        guard let tournamentId = dictionary["tournamentId"] as? String,
              let creatorId = dictionary["creatorId"] as? String,
              let creatorProfileImageURLString = dictionary["creatorProfileImageURL"] as? String,
              let creatorProfileImageURL = URL(string: creatorProfileImageURLString),
              let creatorUsername = dictionary["creatorUsername"] as? String,
              let videoURLString = dictionary["videoURL"] as? String,
              let videoURL = URL(string: videoURLString),
              let thumbnailURLString = dictionary["thumbnailURL"] as? String,
              let thumbnailURL = URL(string: thumbnailURLString),
              let views = dictionary["views"] as? Int,
              let votes = dictionary["votes"] as? Int else {
            return nil
        }
        
        self.id = id
        self.creatorId = creatorId
        self.tournamentId = tournamentId
        self.creatorProfileImageURL = creatorProfileImageURL
        self.creatorUsername = creatorUsername
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.views = views
        self.votes = votes
        self.judgeVotes = dictionary["judgeVotes"] as? Int
        
    }
    
    init?(tournamentId: String, creatorProfileImageURL: URL, creatorUsername: String, videoURL: URL, thumbnailURL: URL) {
        guard let currentUser = Auth.auth().currentUser else { return nil }
        self.id = UUID().uuidString
        self.creatorId = currentUser.uid
        self.tournamentId = tournamentId
        self.creatorProfileImageURL = creatorProfileImageURL
        self.creatorUsername = creatorUsername
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.views = 0
        self.votes = 0
        self.judgeVotes = 0
    }
    
    var dictionary: [String : Any] {
        return [
            "id": id,
            "creatorId": creatorId,
            "tournamentId": tournamentId,
            "creatorProfileImageURL": creatorProfileImageURL.absoluteString,
            "creatorUsername": creatorUsername,
            "videoURL": videoURL.absoluteString,
            "thumbnailURL": thumbnailURL.absoluteString,
            "views": views,
            "votes": votes,
            "judgeVotes": judgeVotes
        ]
    }
}
