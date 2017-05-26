import HTTP
import Cookies

/// Detects and exposes a SessionModel. Captures cookies and finds the appropriate SessionModel for a Cookie if possible and adds it to a Request.
open class SessionsMiddleware<Model: SessionModel>: Middleware {
    /// The cookie to associate with the session
    let cookieName: String
    
    public typealias TokenReader = ((Request) -> String?)
    public typealias TokenWriter = ((String, Response) -> ())
    
    open var tokenReader: TokenReader
    open var tokenWriter: TokenWriter
    
    /// Creates a new session middleware
    ///
    /// Session middlewares are generic towards a SessionModel
    public init(cookieName: String = "meow-session", tokenReader: TokenReader? = nil, tokenWriter: TokenWriter? = nil) {
        self.cookieName = cookieName
        
        self.tokenReader = tokenReader ?? { request in
            return request.cookies[cookieName]
        }
        
        self.tokenWriter = tokenWriter ?? { token, response in
            let cookie = Cookie(name: cookieName, value: token, httpOnly: true)
            response.cookies.insert(cookie)
        }
    }
    
    /// Captures the request and injects session metadata of `Model`'s type
    public func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let session: Model?
        let new: Bool
        
        if let identifier = tokenReader(request), let s = try Model.findOne("sessionToken" == identifier)
        {
            session = s
            new = false
        } else {
            session = try Model(from: request)
            new = true
        }
        
        request.sessionModel = session
        
        let hash = session?.serialize().meowHash
        
        let response = try chain.respond(to: request)
        
        defer {
            if new, let token = session?.sessionToken {
                tokenWriter(token, response)
            }
        }
        
        if let session = session {
            if session.shouldDestroy {
                try session.delete()
            } else if hash != session.serialize().meowHash {
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
