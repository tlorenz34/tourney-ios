//
//  TournamentManager.swift
//  Tourney
//
//  Created by German Espitia on 10/8/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation

/**
 Interface for `Tournament` between database and client.
 */
struct TournamentManager {
    
    func fetchActiveTournaments(completion: @escaping (([Tournament]?) -> Void)) {
        completion(nil)
    }
}
