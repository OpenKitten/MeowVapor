import HTTP
import Crypto
import MongoKitten

/// A Model that keeps track of a session for your user. Can be customized to hold any Meow supported data types
///
/// All variables in the SessionModels except the _id are assumed to have a default value which need not be set in the initializer.
public protocol SessionBaseModel : BaseModel {
    /// A session identifier used in a cookie
    var sessionToken: String { get }
    
    /// When `true`, it will be destroyed. Can be implemented, for example, to keep sessions alive for a set duration
    var shouldDestroy: Bool { get }
    
    /// Creates a brand-new Session with default settings
    init?(for request: Request) throws
    
    /// Used to generate a new random session token
    static func generateSessionToken() -> String
}

/// A Model that keeps track of a session for your user. Can be customized to hold any Meow supported data types
///
/// All variables in the SessionModels except the _id are assumed to have a default value which need not be set in the initializer.
public protocol SessionModel : SessionBaseModel, Model {}

extension SessionModel {
    /// Used to generate a new random session token
    public static func generateSessionToken() -> String {
        return try! Crypto.Random.bytes(count: 20).base64Encoded.makeString()
    }
    
    /// When `true`, it will be destroyed. Can be implemented, for example, to keep sessions alive for a set duration
    public var shouldDestroy: Bool {
        return false
    }
    
    /// Gets the current Session Model of this type from a request
    ///
    /// - parameters request: The request to extract this SessionModel from
    public static func current(for request: Request) -> Self? {
        return request.sessionModel as? Self
    }
}

extension Request {
    /// Gets a SessionModel of the provided type
    public func getSession<S: SessionModel>(_ type: S.Type) -> S? {
        return S.current(for: self)
    }
}
