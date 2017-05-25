import Cookies
import XCTest
@testable import MeowVapor
import HTTP

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
        
        XCTAssertEqual(response.body.bytes ?? [], "success".makeResponse().body.bytes ?? [])
        
        response = try runRequest(cookies: response.cookies) { request in
            guard let userSession = UserSession.current(for: request) else {
                XCTFail()
                return "fail".makeResponse()
            }
            
            XCTAssertNotNil(userSession.user)
            XCTAssertEqual(userSession.user?.username, "Joannis")
            
            userSession.user = user
            
            XCTAssertNotNil(userSession.user)
            
            return "success".makeResponse()
        }
        
        XCTAssertEqual(response.body.bytes ?? [], "success".makeResponse().body.bytes ?? [])
    }
    
//    static var allTests = [
//        ("testExample", testJSON),
//    ]
}

class UserSession : SessionModel {
    var user: User? = nil

// sourcery:inline:auto:UserSession.MeowVapor
	public let _id: String = UserSession.generateSessionToken()

    public required init(){}
// sourcery:end

// sourcery:inline:auto:UserSession.Meow
	@available(*, unavailable, message: "This API is internal to Meow. You can create a new instance using your own inits or using init(newFrom:).")
	public required init(restoring source: BSON.Primitive, key: String) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: UserSession.self, source: source, expectedPrimitive: BSON.Document.self)
		}

		
		self.user = try document.meowHasValue(Key.user) ? document.unpack(Key.user.keyString) : nil
	}

	public required init(newFrom source: BSON.Primitive) throws {
		guard let document = source as? BSON.Document else {
			throw Meow.Error.cannotDeserialize(type: UserSession.self, source: source, expectedPrimitive: BSON.Document.self)
		}
		
		self.user = (try? document.unpack(Key.user.keyString)) ?? self.user
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
