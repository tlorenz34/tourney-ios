//
//  AdminManager.swift
//  Tourney
//
//  Created by German Espitia on 1/6/21.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation
import Firebase

struct AdminManager {
    
    let db = Firestore.firestore()
    private let adminCollectionKey = "admin"
    private var baseQuery: Query {
        return db.collection(adminCollectionKey)
    }
    /**
     Fetch `Tournament` objects with `active` property as `true`
     */
    func fetchTournamentLengthDays(completion: @escaping ((Int?) -> Void)) {
        baseQuery.whereField(FieldPath.documentID(), isEqualTo: "admin").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            guard let doc = snapshot.documents.first,
                  let days = doc.data()["tournamentLengthDays"] as? Int else {
                completion(nil)
                return
            }
            
            completion(days)
            return
        }
        completion(nil)
    }
}
