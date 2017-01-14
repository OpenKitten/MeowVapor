import MeowVapor
import Foundation

final class Tutorial: Model {
    var id = ObjectId()
    var name: String = ""
    var author: String = ""
    var medium: Medium = .article
    var image: String = ""
    var url: String = ""
    var description: String = ""
    var duration: Int = 0
    var difficulty: Difficulty = .easy
    var exists: Bool = false
    
    // sourcery: api=get,pathSuffix=/,permissions=anonymous
    static func list() throws -> Cursor<Tutorial> {
        return try Tutorial.find()
    }
    
    // sourcery: api=post,data=json,pathSuffix=/,permissions=anonymous
    static func create(name: String, author: String, url: String, image: String?) throws -> Tutorial {
        let tutorial = Tutorial(named: name, author: author, url: url, image: image)
        try tutorial.save()
        
        return tutorial
    }
    
    // sourcery: api=delete,permissions=anonymous
    func remove() throws {
        try self.remove()
    }
    
    init(named name: String, author: String, url: String, image: String?) {
        self.name = name
        self.author = author
        self.url = url
        self.image = image ?? ""
    }
}

enum Difficulty: String, Embeddable {
    case easy, intermediate, advanced
}

enum Medium: String, Embeddable {
    case video, article
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
