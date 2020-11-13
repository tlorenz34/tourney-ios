//
//  TournamentManager.swift
//  Tourney
//
//  Created by German Espitia on 10/8/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation
import Firebase
/**
 Interface for `Tournament` between database and client.
 */
struct TournamentManager {
    
    let db = Firestore.firestore()
    private let tournamentsCollectionKey = "tournaments"
    private var baseQuery: Query {
        return db.collection(tournamentsCollectionKey)
    }
    /**
     Fetch `Tournament` objects with `active` property as `true`
     */
    func fetchActiveTournaments(completion: @escaping (([Tournament]?) -> Void)) {
        baseQuery.whereField("active", isEqualTo: true).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            completion(self.parseDocumentsToTournaments(documents: snapshot.documents))
        }
        completion(nil)
    }
    /**
     Fetch child `Tournament`where `currentUser` is the featured video uploader.
     */
    func fetchWonTournaments(completion: @escaping (([Tournament]?) -> Void)) {
        guard let currentUser = Auth.auth().currentUser else { return }
        baseQuery
            .whereField("parentTournamentWinnerId", isEqualTo: currentUser.uid)
            .whereField("active", isEqualTo: true)
            .getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            completion(self.parseDocumentsToTournaments(documents: snapshot.documents))
        }
        completion(nil)
    }
    /**
     Update given `Tournament` by saving it to the database.
     */
    public func save(_ tournament: Tournament) {
        let tournamentRef = db.collection(tournamentsCollectionKey).document(tournament.id)
        tournamentRef.updateData(tournament.dictionary)
    }
    
    /**
     Parse array of `QueryDocumentSnapshot` objects to array of `Tournament` objects
     */
    private func parseDocumentsToTournaments(documents: [QueryDocumentSnapshot]) -> [Tournament] {
        var tournaments: [Tournament] = []
        for document in documents {
            if let tournament = parseDocumentToTournament(document: document) {
                tournaments.append(tournament)
            }
        }
        return tournaments
    }
    /**
     Parse `QueryDocumentSnapshot` to `Tournament`
     */
    private func parseDocumentToTournament(document: QueryDocumentSnapshot) -> Tournament? {
        if let tournament = Tournament(id: document.documentID, dictionary: document.data()) {
            return tournament
        } else {
            return nil
        }
    }
}
