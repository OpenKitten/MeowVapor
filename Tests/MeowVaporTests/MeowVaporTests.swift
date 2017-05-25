import XCTest
@testable import MeowVapor

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
    
    func testSessions() throws {
        
    }
    
//    static var allTests = [
//        ("testExample", testJSON),
//    ]
}

class UserSession : SessionModel {
    var user: Reference<User>? = nil

// sourcery:inline:auto:UserSession.MeowVapor
	public let _id: String = generateSessionToken()

    public required init(identifier: String) {
    	self._id = identifier
    }
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
