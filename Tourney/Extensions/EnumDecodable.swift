//
//  EnumDecodable.swift
//  Tourney
//
//  Created by Hakan Eren on 27.01.2021.
//  Copyright © 2021 Will Cohen. All rights reserved.
//

protocol EnumDecodable: RawRepresentable, Decodable {
    static var `default`: Self { get }
}

extension EnumDecodable where RawValue: Decodable {
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(RawValue.self)
        self = Self(rawValue: value) ?? Self.`default`
    }
    
}
