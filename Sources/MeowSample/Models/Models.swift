import MeowVapor
import Foundation

final class User: Model {
    var id = ObjectId()
    var email: String = ""
    var name: String = ""
    var gender: Gender?
    var favouriteNumbers: [Int] = []
    
    // sourcery: api=get,pathSuffix=/,permissions=anonymous
    static func list() throws -> Cursor<User> {
        return try User.find()
    }
    
    // sourcery: api=get,data=query,pathSuffix=filtered,permissions=anonymous
    static func find(email: String) throws -> User? {
        return try User.findOne { user in
            return user.email == email && user.gender == .male
        }
    }
    
    // sourcery: api=get,data=query,pathSuffix=containing,permissions=anonymous
    static func find(containing email: String) throws -> User? {
        return try User.findOne { user in
            return user.email.contains(email)
        }
    }
    
    // sourcery: api=delete,pathSuffix=/,permissions=anonymous
    func remove() throws {
        try self.delete()
    }
    
    init(email: String, name: String, gender: Gender?) {
        self.email = email
        self.name = name
        self.gender = gender
    }
}

enum Gender: String, Embeddable {
    case male, female
}
