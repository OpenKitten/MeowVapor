// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: Meow.ejs
// MARK: MeowCore.ejs


// MARK: - General Information
// Supported Primitives: ObjectId, String, Int, Int32, Bool, Document, Double, Data, Binary, Date, RegularExpression
// Sourcery Types: class MeowVaporTests, class User, class UserSession
import Foundation
import Meow
import ExtendedJSON
import MeowVapor
import Vapor
import HTTP


// MARK: Protocols.ejs




// MARK: - 🐈 for User
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension User : SerializableToDocument {

	

	public func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.username, as: Key.username.keyString)
        


		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.username.keyString) {
			_ = (try document.unpack(Key.username.keyString)) as String
		}
	}

	public func update(with document: Document) throws {
		try User.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.username.keyString:
				self.username = try document.unpack(Key.username.keyString)
			default: break
			}
		}
	}

	
	
	public static let collection: MongoKitten.Collection = Meow.database["users"]
	

	// MARK: ModelResolvingFunctions.ejs


	public static func byId(_ value: ObjectId) throws -> User? {
		return try User.findOne("_id" == value)
	}




	public static func byUsername(_ value: String) throws -> User? {
		return try User.findOne(Key.username.rawValue == value)
	}


	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		case _id
		case username = "username"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			case ._id: return ObjectId.self
			case .username: return String.self
			}
		}

		public static var all: Set<Key> {
			return [._id, .username]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a User
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive, key: String) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: User.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var username: String?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.username, as: Key.username.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.username.keyString:
					self.username = try document.unpack(Key.username.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: User?) -> Query {
		
		return (lhs.referencedKeyPrefix + "_id") == rhs?._id
		
	}

	public let keyPrefix: String

	public let isReference: Bool

	
	public var _id: VirtualObjectId {
		return VirtualObjectId(name: referencedKeyPrefix + Key._id.keyString)
	}
	

	
		 /// username: String
		 public var username: VirtualString { return VirtualString(name: referencedKeyPrefix + Key.username.keyString) } 

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = isReference
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension User : CustomStringConvertible {
	public var description: String {
	
		return "User<\(ObjectIdentifier(self).hashValue),\((self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString())>"
	
	}
}



// MARK: Parameterizable.ejs
extension User : Parameterizable {
	public static var uniqueSlug: String {
		return "user"
	}

	public static func make(for parameter: String) throws -> User {
		return try Meow.Helpers.requireValue(User.findOne("_id" == ObjectId(parameter)), keyForError: "User from URL parameter")
	}
}




// MARK: - 🐈 for UserSession
// MARK: Serializable.ejs
// MARK: SerializableStructClass.ejs

extension UserSession : SerializableToDocument {

	

	public func serialize() -> Document {
		var document: Document = [:]
		document.pack(self._id, as: "_id")
		document.pack(self.user, as: Key.user.keyString)
        document.pack(self.sessionToken, as: "sessionToken") 


		return document
	}

	public static func validateUpdate(with document: Document) throws {
		let keys = document.keys
		if keys.contains(Key.user.keyString) {
			_ = (try document.unpack(Key.user.keyString)) as User
		}
	}

	public func update(with document: Document) throws {
		try UserSession.validateUpdate(with: document)

		for key in document.keys {
			switch key {
			case Key.user.keyString:
				self.user = try document.unpack(Key.user.keyString)
			default: break
			}
		}
	}

	
	
	public static let collection: MongoKitten.Collection = Meow.database["user_sessions"]
	

	// MARK: ModelResolvingFunctions.ejs


	public static func byId(_ value: ObjectId) throws -> UserSession? {
		return try UserSession.findOne("_id" == value)
	}





	

	// MARK: KeyEnum.ejs

	public enum Key : String, ModelKey {
		case _id
		case user = "user"


		public var keyString: String { return self.rawValue }

		public var type: Any.Type {
			switch self {
			case ._id: return ObjectId.self
			case .user: return User.self
			}
		}

		public static var all: Set<Key> {
			return [._id, .user]
		}
	}

	// MARK: Values.ejs
	

	/// Represents (part of) the values of a UserSession
	public struct Values : ModelValues {
		public init() {}
		public init(restoring source: BSON.Primitive, key: String) throws {
			guard let document = source as? BSON.Document else {
				throw Meow.Error.cannotDeserialize(type: UserSession.Values.self, source: source, expectedPrimitive: BSON.Document.self);
			}
			try self.update(with: document)
		}

		public var user: User?


		public func serialize() -> Document {
			var document: Document = [:]			
			document.pack(self.user, as: Key.user.keyString)
			return document
		}

		public mutating func update(with document: Document) throws {
			for key in document.keys {
				switch key {
				case Key.user.keyString:
					self.user = try document.unpack(Key.user.keyString)
				default: break
				}
			}
		}
	}

	// MARK: VirtualInstanceStructClass.ejs


public struct VirtualInstance : VirtualModelInstance {
	/// Compares this model's VirtualInstance type with an actual model and generates a Query
	public static func ==(lhs: VirtualInstance, rhs: UserSession?) -> Query {
		
		return (lhs.referencedKeyPrefix + "_id") == rhs?._id
		
	}

	public let keyPrefix: String

	public let isReference: Bool

	
	public var _id: VirtualObjectId {
		return VirtualObjectId(name: referencedKeyPrefix + Key._id.keyString)
	}
	

	
		 /// user: User?
		 public var user: User.VirtualInstance { return .init(keyPrefix: referencedKeyPrefix + Key.user.keyString, isReference: true) } 

	public init(keyPrefix: String = "", isReference: Bool = false) {
		self.keyPrefix = keyPrefix
		self.isReference = isReference
	}
} // end VirtualInstance

}

// CustomStringConvertible.ejs


extension UserSession : CustomStringConvertible {
	public var description: String {
	
		return "UserSession<\(ObjectIdentifier(self).hashValue),\((self.serialize() as Document).makeExtendedJSON(typeSafe: false).serializedString())>"
	
	}
}



// MARK: Parameterizable.ejs
extension UserSession : Parameterizable {
	public static var uniqueSlug: String {
		return "user_session"
	}

	public static func make(for parameter: String) throws -> UserSession {
		return try Meow.Helpers.requireValue(UserSession.findOne("_id" == ObjectId(parameter)), keyForError: "UserSession from URL parameter")
	}
}





fileprivate let meows: [Any.Type] = [User.self, UserSession.self]

extension Meow {
	static func `init`(_ connectionString: String) throws {
		try Meow.init(connectionString, meows)
	}

	static func `init`(_ db: MongoKitten.Database) {
		Meow.init(db, meows)
	}
}

// 🐈 Statistics
// Models: 2
//   User, UserSession
// Serializables: 2
//   User, UserSession
// Model protocols: 0
//   
// Tuples: 0
