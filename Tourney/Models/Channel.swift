//
//  Channel.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation

struct Channel {
    let id: String
    let name: String
    let desc: String
    let isLive: Bool
    let coverImageURL: URL?
    let filters: [String]
    
    var dictionary: [String : Any] {
        ["name" : name,
         "desc" : desc,
         "isLive" : isLive,
         "coverImageURL" : coverImageURL?.absoluteString ?? "",
         "filters" : filters]
    }
    
    init?(id: String, dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let desc = dictionary["desc"] as? String,
              let isLive = dictionary["isLive"] as? Bool,
              let filters = dictionary["filters"] as? [String] else {
            return nil
        }
        self.id = id
        self.name = name
        self.desc = desc
        self.isLive = isLive
        self.coverImageURL = URL(string: (dictionary["coverImageURL"] as? String) ?? "")
        self.filters = filters
    }
}
