import HTTP
import Cookies

/// Detects and exposes a SessionModel. Captures cookies and finds the appropriate SessionModel for a Cookie if possible and adds it to a Request.
public final class SessionsMiddleware<Model: SessionModel>: Middleware {
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
        let session: Model?
        
        if let identifier = request.cookies[cookieName], let s = try Model.findOne("sessionToken" == identifier)
        {
            session = s
        } else {
            session = try Model(for: request)
        }
        
        request.sessionModel = session
        
        let hash = session?.serialize().meowHash
        
        let response = try chain.respond(to: request)
        
        if let session = session {
            let cookie = Cookie(name: cookieName, value: session.sessionToken, httpOnly: true)
            
            if session.shouldDestroy {
                try session.delete()
            } else if hash != session.serialize().meowHash {
                response.cookies.insert(cookie)
                try session.save()
            }
        }
        
        return response
    }
    
}

extension Request {
    /// The session model associated with this request, if any.
    ///
    /// Can be cast using `as?` to a specific `SessionModel` implementing type
    public var sessionModel: SessionBaseModel? {
        get {
            return self.storage["meow-vapor:sessions"] as? SessionBaseModel
        }
        set {
            self.storage["meow-vapor:sessions"] = newValue
        }
    }
}
