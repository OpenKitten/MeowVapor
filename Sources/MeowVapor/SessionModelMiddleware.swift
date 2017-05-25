import HTTP
import Cookies

/// Detects and exposes a SessionModel. Captures cookies and finds the appropriate SessionModel for a Cookie if possible and adds it to a Request.
public final class SessionsMiddleware<Model: SessionModel>: Middleware {
    /// A SessionManager for a specific Model
    let sessionManager = SessionManager<Model>()
    
    /// The cookie to associate with the session
    let cookieName: String
    
    /// Creates a new session middleware
    ///
    /// Session middlewares are generic towards a SessionModel
    public init(cookieName: String = "meow-session") {
        self.cookieName = cookieName
    }
    
    /// Captures the request and injects session metadata of `Model`'s type
    public func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let session: Model
        
        if let identifier = request.cookies[cookieName], let s = try sessionManager.get(identifier: identifier)
        {
            session = s
        } else {
            session = Model()
        }
        
        request.sessionModel = session
        
        let hash = session.serialize().meowHash
        
        let response = try chain.respond(to: request)
        
        let cookie = Cookie(name: cookieName, value: session._id, httpOnly: true)
        
        if session.shouldDestroy {
            try sessionManager.destroy(identifier: session._id)
        } else if hash != session.serialize().meowHash {
            response.cookies.insert(cookie)
            try sessionManager.set(session)
        }
        
        return response
    }
    
}

extension Request {
    /// The session model associated with this request, if any.
    ///
    /// Can be cast using `as?` to a specific `SessionModel` implementing type
    public var sessionModel: SessionModel? {
        get {
            return self.storage["meow-vapor:sessions"] as? SessionModel
        }
        set {
            self.storage["meow-vapor:sessions"] = newValue
        }
    }
}
