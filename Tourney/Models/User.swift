//
//  User.swift
//  goldcoastleague
//
//  Created by Will Cohen on 7/17/19.
//  Copyright © 2019 Thaddeus Lorenz. All rights reserved.
//

import Foundation

final class User {
    static let sharedInstance = User()
    private init() { }
    
    var uid: String!
    var username: String!
    var profileImageURL: String!
    
    var activeFilter: String!
    
}


