//
//  User.swift
//  goldcoastleague
//
//  Created by Will Cohen on 7/17/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

// When a user signs up, they create a username, profile picture
import Foundation

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


