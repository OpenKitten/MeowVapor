import JSON
import Cookies
import XCTest
@testable import MeowVapor
import HTTP
import struct Cheetah.JSONArray
import struct Cheetah.JSONObject
import protocol Cheetah.Value

class MeowVaporTests: XCTestCase {
//    func testJSON() throws {
//        let json: JSONObject = [
//            "username": "Joannis",
//            "password": "hunter2",
//            "pi": 3.14,
//            "favourites": ["Swift", "MongoDB"] as JSONArray
//        ]
//        
//        let vaporJSON = JSON(.object([
//            "username": "Joannis",
//            "password": "hunter2",
//            "pi": 3.14,
//            "favourites": JSON(.array(["Swift", "MongoDB"]))
//        ]))
//        
//        XCTAssertEqual(try json.makeJSON(), vaporJSON)
//    }
    
    override func setUp() {
        try! Meow.init("mongodb://localhost/meowvapor")
        try! Meow.database.drop()
    }
    
    func testCheetahVaporJSONConversion() throws {
        let json: JSON = [
            "key": 3,
            "pi": 3.14,
            "username": "Henk",
            "admin": true,
            "nums": [1, 2, 3, 4, 5, 6, 7, 9]
        ]
        
        let cheetahJSON = try JSONObject(json: json)
        
        XCTAssertEqual(cheetahJSON, [
            "key": 3,
            "pi": 3.14,
            "username": "Henk",
            "admin": true,
            "nums": [1, 2, 3, 4, 5, 6, 7, 9] as JSONArray
        ])
        
        XCTAssertEqual(try cheetahJSON.makeJSON(), json)
    }
    
    func testSessions() throws {
        let middleware = SessionsMiddleware<UserSession>()
        
        func runRequest(method: HTTP.Method = .get, uri: String = "login", cookies: Cookies = Cookies(), _ closure: @escaping BasicResponder.Closure) throws -> Response {
            let request = Request(method: method, uri: uri)
            request.cookies = cookies
            
            return try middleware.respond(to: request, chainingTo: BasicResponder(closure))
        }
        
        let user = User(username: "Joannis")
        try user.save()
        
        var response = try runRequest { request in
            guard let userSession = UserSession.current(for: request) else {
                XCTFail()
                return "fail".makeResponse()
            }
            
            XCTAssertNil(userSession.user)
            
            userSession.user = user
            
            XCTAssertNotNil(userSession.user)
            
            return "success".makeResponse()
        }
        
        guard let token = response.cookies[middleware.cookieName] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(response.body.bytes ?? [], "success".makeResponse().body.bytes ?? [])
        
        response = try runRequest(cookies: response.cookies) { request in
            guard let userSession = UserSession.current(for: request) else {
                XCTFail()
                return "fail".makeResponse()
            }
            
            XCTAssertNotNil(userSession.user)
            XCTAssertEqual(userSession.user?.username, "Joannis")
            
            return "success".makeResponse()
        }
        
        let sessionUser = try UserSession.findOne("sessionToken" == token)?.user
        
        XCTAssertNotNil(sessionUser)
        XCTAssert(user == sessionUser)
        
        XCTAssertEqual(response.body.bytes ?? [], "success".makeResponse().body.bytes ?? [])
    }
    
//    static var allTests = [
//        ("testExample", testJSON),
//    ]
}

final class UserSession : SessionModel {
    var user: User? = nil

    init?(from request: Request) throws {}
    
// sourcery:inline:auto:UserSession.MeowVapor
    /// A session identifier used in a cookie
    public private(set) var sessionToken: String = UserSession.generateSessionToken()
// sourcery:end

// sourcery:inline:auto:UserSession.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: UserSession.self, source: source, expectedPrimitive: BSON.Document.self)
		}
        Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.user = try document.meowHasValue(Key.user) ? document.unpack(Key.user.keyString) : nil
        self.sessionToken = try document.unpack("sessionToken")

	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: UserSession.self, source: source, expectedPrimitive: BSON.Document.self)
		}
		
		self.user = (try? document.unpack(Key.user.keyString)) ?? self.user
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}

final class User : Model {
    var username: String
    
    init(username: String) {
        self.username = username
    }

// sourcery:inline:auto:User.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self)
		}
        Meow.pool.free(self._id)
		self._id = try document.unpack("_id")
		self.username = try document.unpack(Key.username.keyString)
        

	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: User.self, source: source, expectedPrimitive: BSON.Document.self)
		}
		
		self.username = (try document.unpack(Key.username.keyString)) 
	}
	public var _id = Meow.pool.newObjectId() { didSet { Meow.pool.free(oldValue) } }

	deinit {
		Meow.pool.handleDeinit(self)
	}
// sourcery:end
}
