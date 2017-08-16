//import MeowVapor
//import HTTP
//
//final class UserSession : SessionModel {
//    var user: User? = nil
//    
//    init?(from request: Request) throws {}
//    
//    // sourcery:inline:auto:UserSession.MeowVapor
//    /// A session identifier used in a cookie
//    public private(set) var sessionToken: String = UserSession.generateSessionToken()
//    // sourcery:end
//    
//    // sourcery:inline:auto:UserSession.Meow
//    @available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
//    public required init(restoring source: BSON.Primitive, key: String) throws {
//        guard let document = source as? BSON.Document else {
//            throw Meow.Error.cannotDeserialize(type: UserSession.self, source: source, expectedPrimitive: BSON.Document.self)
//        }
//        Meow.pool.free(self._id)
//        self._id = try document.unpack("_id")
//        self.user = try document.meowHasValue(Key.user) ? document.unpack(Key.user.keyString) : nil
//        self.sessionToken = try document.unpack("sessionToken")
//        
//    }
//    
//    public required init(newFrom source: BSON.Primitive) throws {
//        guard let document = source as? BSON.Document else {
//            throw Meow.Error.cannotDeserialize(type: UserSession.self, source: source, expectedPrimitive: BSON.Document.self)
//        }
//        
//        self.user = (try? document.unpack(Key.user.keyString)) ?? self.user
//    }
//    public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }
//    
//    deinit {
//        Meow.pool.handleDeinit(self)
//    }
//    // sourcery:end
//}
//
//final class User : Model {
//    var username: String
//    
//    init(username: String) {
//        self.username = username
//    }
//    
//    // sourcery:inline:auto:User.Meow
//    @available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
//    public required init(restoring source: BSON.Primitive, key: String) throws {
//        guard let document = source as? BSON.Document else {
//            throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self)
//        }
//        Meow.pool.free(self._id)
//        self._id = try document.unpack("_id")
//        self.username = try document.unpack(Key.username.keyString)
//        
//        
//    }
//    
//    public required init(newFrom source: BSON.Primitive) throws {
//        guard let document = source as? BSON.Document else {
//            throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self)
//        }
//        
//        self.username = (try document.unpack(Key.username.keyString)) 
//    }
//    public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }
//    
//    deinit {
//        Meow.pool.handleDeinit(self)
//    }
//    // sourcery:end
//}

