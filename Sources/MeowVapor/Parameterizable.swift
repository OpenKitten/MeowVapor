//
//  Parameterizable.swift
//  MeowVapor
//
//  Created by Robbert Brandsma on 20/06/2017.
//

import Meow
import Vapor

public extension Model where Self : Parameterizable {
    
    public static var uniqueSlug: String {
        return String(describing: Self.self)
    }
    
    public static func make(for parameter: String) throws -> Self {
        return try Meow.Helpers.requireValue(Self.findOne("_id" == ObjectId(parameter)), keyForError: "\(Self.self) from URL parameter")
    }
    
}
