//
//  FilterManager.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation
import Firebase
/**
 Interface for `Filter` between database and client.
 */
struct FilterManager {
    
    let db = Firestore.firestore()
    private let filtersCollectionKey = "filters"
    private var baseQuery: Query {
        return db.collection(filtersCollectionKey)
    }
    
    func fetchFilters(completion: @escaping ( ([Filter]?) -> Void)) {
        baseQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            completion(snapshot.documents.compactMap { Filter(id: $0.documentID, dictionary: $0.data()) })
        }
    }
}
