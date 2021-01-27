//
//  ChallengeType.swift
//  Tourney
//
//  Created by Hakan Eren on 27.01.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

enum ChallengeType: String, EnumDecodable, Encodable {
    static var `default`: ChallengeType {
        `public`
    }
    
    case `public` = "Public"
    
    case oneVone = "1v1"
    
    case `private` = "Private"
}
