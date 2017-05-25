import HTTP
import Cookies

/// Detects and exposes a SessionModel. Captures cookies and finds the appropriate SessionModel for a Cookie if possible and adds it to a Request.
public final class SessionsMiddleware<Model: SessionModel>: Middleware {
    let sessionManager = SessionManager<Model>()
    let cookieName: String
    
    public init(cookieName: String = "meow-session") {
        self.cookieName = cookieName
    }
    
    public func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let session: Model
        
        if let identifier = request.cookies[cookieName], let s = try sessionManager.get(identifier: identifier)
        {
            session = s
        } else {
            session = Model(identifier: try sessionManager.makeIdentifier())
        }
        
        request.sessionModel = session
        
        let hash = session.serialize().meowHash
        
        let response = try chain.respond(to: request)
        
        let cookie = Cookie(name: cookieName, value: session._id, httpOnly: true)
        
        if session.shouldDestroy {
            try sessionManager.destroy(identifier: session._id)
        } else if hash == session.serialize().meowHash {
            response.cookies.insert(cookie)
            try sessionManager.set(session)
        }
        
        return response
    }
    
}

extension Request {
    public var sessionModel: SessionModel? {
        get {
            return self.storage["meow-vapor:sessions"] as? SessionModel
        }
        set {
            self.storage["meow-vapor:sessions"] = newValue
        }
    }
}
