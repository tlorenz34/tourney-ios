//
//  Filter.swift
//  Tourney
//
//  Created by Hakan Eren on 9.02.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation

struct Filter {
    let id: String
    let name: String
    
    var dictionary: [String : Any] {
        ["name" : name]
    }
    
    init?(id: String, dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String else {
            return nil
        }
        self.id = id
        self.name = name
    }
}
