import MongoKitten
import Sessions
import Vapor
import Crypto

/// Stores the sessions in MongoDB
public class MongoSessions : SessionsProtocol {
    /// The collection to store sessions in
    let collection: MongoKitten.Collection
    
    /// Creates a session storage around a collection
    init(in collection: MongoKitten.Collection) {
        self.collection = collection
    }
    
    /// Creates a session storage around the `_sessions` collection in this database
    init(in database: MongoKitten.Database) {
        self.collection = database["_sessions"]
    }
    
    /// Creates a new session token
    public func makeIdentifier() throws -> String {
        return try Crypto.Random.bytes(count: 20).base64Encoded.makeString()
    }
    
    /// Gets the session for this token
    public func get(identifier: String) throws -> Session? {
        guard var sessionDocument = try collection.findOne("_id" == identifier) else {
            return nil
        }
        
        sessionDocument.removeValue(forKey: "_id")
        
        return Session(identifier: identifier, data: Node([:], in: sessionDocument))
    }
    
    /// Sets a new session's values
    public func set(_ session: Session) throws {
        try collection.update("_id" == session.identifier, to: ["_id" : session.identifier] + session.document, upserting: true)
    }
    
    /// Destroys a session
    public func destroy(identifier: String) throws {
        try collection.remove("_id" == identifier)
    }
}

extension Session {
    /// The session storage (BSON required)
    var document: Document {
        get {
            return (self.data.context as? Document) ?? [:]
        }
        set {
            self.data.context = newValue
        }
    }
}

extension Document : Context {}
