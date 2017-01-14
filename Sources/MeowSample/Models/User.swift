import MeowVapor
import Foundation

final class Tutorial: Model {
    var id = ObjectId()
    var name: String = ""
    var author: String = ""
    //var medium: Medium
    var image: String = ""
    var url: String = ""
    var description: String = ""
    var duration: Int = 0
    var difficulty: Difficulty = .easy
    var exists: Bool = false
}

enum Difficulty: String, Embeddable {
    case easy, intermediate, advanced
}


//
//final class House : Model {
//    var id = ObjectId()
//    
//    var owner: Reference<User, Deny>?
//}
//
//final class User : Model, DynamicSerializable {
//    var additionalFields = Document()
//    var id = ObjectId()
//    
//    var email: String
//    var firstName: String?
//    var lastName: String?
//    var passwordHash: Data?
//    var registrationDate: Date
//    var preferences = Preferences()
//    var pet: Reference<Dog, Cascade>
//    var boss: Reference<User, Ignore>?
//    
//    // sourcery: api=get,data=query,permissions=anonymous
//    func customFieldUpdate(key: String, value: String) throws {
//        self.additionalFields[key] = value
//        try self.save()
//    }
//    
//    // sourcery: api=get,data=query,permissions=anonymous
//    func update(email: String, firstName: String? = nil, lastName: String? = nil) throws {
//        self.email = email
//        
//        if let firstName = firstName {
//            self.firstName = firstName
//        }
//        
//        if let lastName = lastName {
//            self.lastName = lastName
//        }
//        
//        try self.save()
//    }
//    
//    // sourcery: api=post,data=json,permissions=anonymous
//    static func register(email: String) throws -> User {
//        let user = try User(email: email)
//        try user.save()
//        
//        return user
//    }
//    
//    // sourcery: api=get,permissions=anonymous
//    func get() throws -> User {
//        return self
//    }
//    
//    // sourcery: api=get,permissions=anonymous
//    func dog() throws -> Dog {
//        return try self.pet.resolve()
//    }
//    
//    init(email: String) throws {
//        self.email = email
//        self.registrationDate = Date()
//        let pet = Dog()
//        try pet.save()
//        self.pet = Reference(pet)
//    }
//}
//
//final class Preferences : Embeddable {
//    var likesCheese: Bool = false
//}
//
//final class Dog : Model {
//    var id = ObjectId()
//    var name: String = "Fluffy"
//    
//    var preferences: Preferences?
//}
//
//final class Flat : Model {
//    var id = ObjectId()
//    
//    var owners: [Reference<User, Cascade>] = []
//}
