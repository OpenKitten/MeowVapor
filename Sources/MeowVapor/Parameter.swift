//
//  Parameterizable.swift
//  MeowVapor
//
//  Created by Robbert Brandsma on 20/06/2017.
//

import Meow
import Vapor

extension ObjectId: Parameter {
    public static var uniqueSlug: String {
        return "ObjectId"
    }
    
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> ObjectId {
        return try ObjectId(parameter)
    }
}

public extension Model where Self: Parameter, Self.Identifier == ObjectId {
    public static var uniqueSlug: String {
        return String(describing: Self.self)
    }
    
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> EventLoopFuture<Self> {
        let id = try ObjectId(parameter)
        let context = try container.make(Meow.Context.self)
        
        return context.findOne(Self.self, where: "_id" == id).thenThrowing { instance in
            guard let instance = instance else {
                throw MeowVaporError.modelInParameterNotFound
            }
            
            return instance
        }
    }
}

public extension Model where Self: Parameter, Self.Identifier == String {
    public static var uniqueSlug: String {
        return String(describing: Self.self)
    }
    
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> EventLoopFuture<Self> {
        let context = try container.make(Meow.Context.self)
        
        return context.findOne(Self.self, where: "_id" == parameter).thenThrowing { instance in
            guard let instance = instance else {
                throw MeowVaporError.modelInParameterNotFound
            }
            
            return instance
        }
    }
}
