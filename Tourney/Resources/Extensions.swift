//
//  Extensions.swift
//  Tourney
//
//  Created by German Espitia on 10/20/20.
//  Copyright © 2020 Will Cohen. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
