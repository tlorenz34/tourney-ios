//
//  ChannelManager.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation
import Firebase
/**
 Interface for `Channel` between database and client.
 */
struct ChannelManager {
    
    let db = Firestore.firestore()
    private let channelsCollectionKey = "channels"
    private var baseQuery: Query {
        return db.collection(channelsCollectionKey)
    } 
    
    func fetchFeaturedChannels(completion: @escaping ( ([Channel]?) -> Void)) {
        baseQuery.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            completion(snapshot.documents.compactMap { Channel(id: $0.documentID, dictionary: $0.data()) })
        }
    }
    
}
