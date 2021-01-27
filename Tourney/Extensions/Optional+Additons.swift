//
//  Optional+Additons.swift
//  Tourney
//
//  Created by Hakan Eren on 27.01.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
