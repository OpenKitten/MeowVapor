//
//  Cache.swift
//  MeowVapor
//
//  Created by Joannis Orlandos on 19/05/2017.
//
//

import Cache
import Vapor

public final class MeowCache : CacheProtocol {
    public func set(_ key: String, _ value: Node, expiration: Date?) throws {
        try collection.update("_id" == key, to: [
            "_id": key,
            "value": value,
            "expiration": expiration
            ], upserting: true)
    }

    /// The collection in which cached data will be stored
    let collection: MongoKitten.Collection
    
    /// Creates a session storage around a collection
    public init(in collection: MongoKitten.Collection) throws {
        self.collection = collection
        
        try self.collection.createIndex(named: "ttl", withParameters: .sort(field: "expiration", order: .ascending), .expire(afterSeconds: 0))
    }
    
    /// Creates a session storage around the `_sessions` collection in this database
    public convenience init(in database: MongoKitten.Database) throws {
        try self.init(in: database["_sessions"])
    }
    
    public func get(_ key: String) throws -> Node? {
        guard let value = try collection.findOne("_id" == key)?["value"] else {
            return nil
        }
        
        return value.makeNode()
    }
    
    public func set(_ key: String, _ value: Node) throws {
        try collection.update("_id" == key, to: [
            "_id": key,
            "value": value
        ], upserting: true)
    }
    
    public func delete(_ key: String) throws {
        try collection.remove("_id" == key)
    }
}
