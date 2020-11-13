//
//  API.swift
//  Tourney
//
//  Created by German Espitia on 11/12/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation
import FirebaseFunctions

/**
 Interface with Google Cloud Functions
 */
struct API {
    
    let functions = Functions.functions()
    // Flag to denote whether Firebase cloud functions should run locally (test) or via cloud (deployed functions)
    let testing: Bool = false
    
    init() {
        if testing {
            functions.useFunctionsEmulator(origin: "http://localhost:5001")
        }
    }
    /// Endpoints available
    enum Endpoint: String {
        case updateLeaderForTournament = "updateLeaderForTournament"
        case updateParticipantsForTournament = "updateParticipantsForTournament"
    }
    /// Parameters object
    struct updateLeaderForTournamentParams {
        let tournamentId: String
        var dictionary: [String : Any] {
            return [
                "tournamentId": tournamentId
            ]
        }
    }
    /// Parameters  object
    struct updateParticipantsForTournamentParams {
        let tournamentId: String
        var dictionary: [String : Any] {
            return [
                "tournamentId": tournamentId
            ]
        }
    }
    /**
     Updates leader fields of tournament with current leader (most votes)
     */
    func updateLeaderForTournament(tournament: Tournament) {
        
        let params = updateLeaderForTournamentParams(tournamentId: tournament.id)
        
        functions.httpsCallable(Endpoint.updateLeaderForTournament.rawValue).call(params.dictionary) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print(code as Any)
                    print(message)
                    print(details as Any)
                }
            }
            guard let result = result, let data = result.data as? [String : Any] else { return }            
            print(data)
        }
    }
    /**
     Updates `participants` property of tournament object.
     
     **Must be called prior to adding new submission to tournament**
     
     The function works by checking if the user already has a `Submission` object for a given tournament. If first submission to tournament is added first and then `updateParticipantsForTournament` is called - it will assume that the user is alrady counted as a participant.
     */
    func updateParticipantsForTournament(tournament: Tournament, completion: @escaping (() -> Void)) {
        
        let params = updateParticipantsForTournamentParams(tournamentId: tournament.id)
        
        functions.httpsCallable(Endpoint.updateParticipantsForTournament.rawValue).call(params.dictionary) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print(code as Any)
                    print(message)
                    print(details as Any)
                    print("Error updating participants for tournament")
                    completion()
                }
            }
            guard let result = result, let data = result.data as? [String : Any] else { return }
            print(data)
            completion()
        }
    }
}
