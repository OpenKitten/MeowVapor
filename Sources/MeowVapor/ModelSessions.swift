import MongoKitten
import Sessions
import Vapor
import Crypto

/// Stores the sessions in MongoDB
public class SessionManager<Model : SessionModel> {
    /// Creates a session storage for a SessionModel
    public init() {}
    
    /// Creates a new session token
    public func makeIdentifier() throws -> String {
        return try Crypto.Random.bytes(count: 20).base64Encoded.makeString()
    }
    
    /// Gets the session for this token
    public func get(identifier: String) throws -> Model? {
        return try Model.get(byIdentifier: identifier)
    }
    
    /// Sets a new session's values
    public func set(_ session: Model) throws {
        let document = session.serialize() + ["_id": session._id]
        
        try Model.collection.update("_id" == session._id, to: document, upserting: true)
    }
    
    /// Destroys a session
    public func destroy(identifier: String) throws {
        try Model.collection.remove("_id" == identifier)
    }
}
