// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import HTTP
import Vapor
import Foundation
import MeowVapor



extension Dog : ConcreteSerializable {
  func meowSerialize() -> Document {
      
        var doc: Document = ["_id": self.id]
      

      

      
        // id: ObjectId (ObjectId)
        
          
        
      
        // name: String (String)
        
          
            doc["name"] = self.name
          
        
      
        // preferences: Preferences? (Preferences)
        
          
            doc["preferences"] = self.preferences?.meowSerialize()
          
        
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
        // loop: id

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        // loop: name

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let nameValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "name") as? String, keyForError: "name")
             
          
      
     
        // loop: preferences

        
          
          
              let preferencesValue: Preferences?
              if let preferencesDocument: Document = source.removeValue(forKey: "preferences") as? Document {
                preferencesValue = try Preferences(fromDocument: preferencesDocument)
              } else {
                preferencesValue = nil
              }
          
        
      
     

      // initializerkaas:
      try self.init(
        
        
      )

      
        
          self.id = idValue
        
      
        
          self.name = nameValue
        
      
        
          self.preferences = preferencesValue
        
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      // name: String
      
        var name: VirtualString { return VirtualString(name: keyPrefix + "name") }
      
    
      // preferences: Preferences?
      
        var preferences: Preferences.VirtualInstance { return Preferences.VirtualInstance(keyPrefix: "preferences.") }
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }

  var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      
        
      

      return result
  }
}

extension Flat : ConcreteSerializable {
  func meowSerialize() -> Document {
      
        var doc: Document = ["_id": self.id]
      

      

      
        // id: ObjectId (ObjectId)
        
          
        
      
        // owners: [Reference<User, Cascade>] ([Reference<User, Cascade>])
        
          
            doc["owners"] = self.owners.map { $0.id }
          
          // TODO: Support [Embeddable]?
        
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
        // loop: id

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        // loop: owners

        
          
            // o the noes it is a reference
            let ownersIds = try Meow.Helpers.requireValue(source.removeValue(forKey: "owners") as? Document, keyForError: "owners").arrayValue
            let ownersValue: [Reference<User, Cascade>]

            
               ownersValue = try ownersIds.map {
                  Reference(restoring: try Meow.Helpers.requireValue($0 as? ObjectId, keyForError: "owners"))
                }
            
          
        
     

      // initializerkaas:
      try self.init(
        
        
      )

      
        
          self.id = idValue
        
      
        
          self.owners = ownersValue
        
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      // owners: [Reference<User, Cascade>]
      
        var owners: VirtualReferenceArray<Reference<User, Cascade>.Model, Reference<User, Cascade>.DeleteRule> { return VirtualReferenceArray<Reference<User, Cascade>.Model, Reference<User, Cascade>.DeleteRule>(name: keyPrefix + "owners") }
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }

  var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      

      return result
  }
}

extension House : ConcreteSerializable {
  func meowSerialize() -> Document {
      
        var doc: Document = ["_id": self.id]
      

      

      
        // id: ObjectId (ObjectId)
        
          
        
      
        // owner: Reference<User, Deny>? (Reference<User, Deny>)
        
          
            doc["owner"] = self.owner?.id
          
        
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
        // loop: id

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        // loop: owner

        
          
             // o the noes it is a reference
             let ownerId: ObjectId? = source.removeValue(forKey: "owner") as? ObjectId
             let ownerValue: Reference<User, Deny>?

             
                if let ownerId = ownerId {
                    ownerValue = Reference(restoring: ownerId)
                } else {
                    ownerValue = nil
                }
             
        
      
     

      // initializerkaas:
      try self.init(
        
        
      )

      
        
          self.id = idValue
        
      
        
          self.owner = ownerValue
        
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      // owner: Reference<User, Deny>?
      
        var owner: VirtualReference<Reference<User, Deny>.Model, Reference<User, Deny>.DeleteRule> { return VirtualReference(name: keyPrefix + "owner") }
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }

  var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
          
            if let ownerValue = self.owner {
          
          result.append(("owner", ownerValue.destinationType, ownerValue.deleteRule, ownerValue.id))
          
            }
          
        
      

      return result
  }
}

extension User : ConcreteSerializable {
  func meowSerialize() -> Document {
      
        var doc: Document = ["_id": self.id]
      

      
        doc += self.additionalFields
      

      
        // additionalFields: Document (Document)
        
          
        
      
        // id: ObjectId (ObjectId)
        
          
        
      
        // email: String (String)
        
          
            doc["email"] = self.email
          
        
      
        // firstName: String? (String)
        
          
            doc["firstName"] = self.firstName
          
        
      
        // lastName: String? (String)
        
          
            doc["lastName"] = self.lastName
          
        
      
        // passwordHash: Data? (Data)
        
          
            doc["passwordHash"] = self.passwordHash
          
        
      
        // registrationDate: Date (Date)
        
          
            doc["registrationDate"] = self.registrationDate
          
        
      
        // preferences: Preferences (Preferences)
        
          
            doc["preferences"] = self.preferences.meowSerialize()
          
        
      
        // pet: Reference<Dog, Cascade> (Reference<Dog, Cascade>)
        
          
            doc["pet"] = self.pet.id
          
        
      
        // boss: Reference<User, Ignore>? (Reference<User, Ignore>)
        
          
            doc["boss"] = self.boss?.id
          
        
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
        // loop: additionalFields

        
          
      
     
        // loop: id

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        // loop: email

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let emailValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "email") as? String, keyForError: "email")
             
          
      
     
        // loop: firstName

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let firstNameValue: String? = source.removeValue(forKey: "firstName") as? String
             
          
      
     
        // loop: lastName

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let lastNameValue: String? = source.removeValue(forKey: "lastName") as? String
             
          
      
     
        // loop: passwordHash

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let passwordHashValue: Data? = source.removeValue(forKey: "passwordHash") as? Data
             
          
      
     
        // loop: registrationDate

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let registrationDateValue: Date = try Meow.Helpers.requireValue(source.removeValue(forKey: "registrationDate") as? Date, keyForError: "registrationDate")
             
          
      
     
        // loop: preferences

        
          
          
              let preferencesDocument: Document = try Meow.Helpers.requireValue(source.removeValue(forKey: "preferences") as? Document, keyForError: "preferences")
              let preferencesValue: Preferences = try Preferences(fromDocument: preferencesDocument)
          
        
      
     
        // loop: pet

        
          
             // o the noes it is a reference
             let petId: ObjectId? = source.removeValue(forKey: "pet") as? ObjectId
             let petValue: Reference<Dog, Cascade>

             
                petValue = Reference(restoring: try Meow.Helpers.requireValue(petId, keyForError: "pet"))
             
        
      
     
        // loop: boss

        
          
             // o the noes it is a reference
             let bossId: ObjectId? = source.removeValue(forKey: "boss") as? ObjectId
             let bossValue: Reference<User, Ignore>?

             
                if let bossId = bossId {
                    bossValue = Reference(restoring: bossId)
                } else {
                    bossValue = nil
                }
             
        
      
     

      // initializerkaas:
      try self.init(
        
        
          email: emailValue
          
        
      )

      
        
          self.additionalFields = source
        
      
        
          self.id = idValue
        
      
        
          self.email = emailValue
        
      
        
          self.firstName = firstNameValue
        
      
        
          self.lastName = lastNameValue
        
      
        
          self.passwordHash = passwordHashValue
        
      
        
          self.registrationDate = registrationDateValue
        
      
        
          self.preferences = preferencesValue
        
      
        
          self.pet = petValue
        
      
        
          self.boss = bossValue
        
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // additionalFields: Document
      
        // Variable: name = additionalFields, typeName = Document, isComputed = false, isStatic = false, readAccess = internal, writeAccess = internal, annotations = [:], attributes = [:]
      
    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      // email: String
      
        var email: VirtualString { return VirtualString(name: keyPrefix + "email") }
      
    
      // firstName: String?
      
        var firstName: VirtualString { return VirtualString(name: keyPrefix + "firstName") }
      
    
      // lastName: String?
      
        var lastName: VirtualString { return VirtualString(name: keyPrefix + "lastName") }
      
    
      // passwordHash: Data?
      
        var passwordHash: VirtualData { return VirtualData(name: keyPrefix + "passwordHash") }
      
    
      // registrationDate: Date
      
        var registrationDate: VirtualDate { return VirtualDate(name: keyPrefix + "registrationDate") }
      
    
      // preferences: Preferences
      
        var preferences: Preferences.VirtualInstance { return Preferences.VirtualInstance(keyPrefix: "preferences.") }
      
    
      // pet: Reference<Dog, Cascade>
      
        var pet: VirtualReference<Reference<Dog, Cascade>.Model, Reference<Dog, Cascade>.DeleteRule> { return VirtualReference(name: keyPrefix + "pet") }
      
    
      // boss: Reference<User, Ignore>?
      
        var boss: VirtualReference<Reference<User, Ignore>.Model, Reference<User, Ignore>.DeleteRule> { return VirtualReference(name: keyPrefix + "boss") }
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }

  var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
      
        
          
            let petValue = self.pet
          
          result.append(("pet", petValue.destinationType, petValue.deleteRule, petValue.id))
          
        
      
        
          
            if let bossValue = self.boss {
          
          result.append(("boss", bossValue.destinationType, bossValue.deleteRule, bossValue.id))
          
            }
          
        
      

      return result
  }
}

extension Preferences : ConcreteSerializable {
  func meowSerialize() -> Document {
      
      var doc = Document()
      

      

      
        // likesCheese: Bool (Bool)
        
          
            doc["likesCheese"] = self.likesCheese
          
        
      

      return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
        // loop: likesCheese

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let likesCheeseValue: Bool = try Meow.Helpers.requireValue(source.removeValue(forKey: "likesCheese") as? Bool, keyForError: "likesCheese")
             
          
      
     

      // initializerkaas:
      try self.init(
        
        
      )

      
        
          self.likesCheese = likesCheeseValue
        
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // likesCheese: Bool
      
        var likesCheese: VirtualBool { return VirtualBool(name: keyPrefix + "likesCheese") }
      
    

    init(keyPrefix: String = "") {
      self.keyPrefix = keyPrefix
    }
  }

  var meowReferencesWithValue: [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)] {
      var result = [(key: String, destinationType: ConcreteModel.Type, deleteRule: DeleteRule.Type, id: ObjectId)]()
      _ = result.popLast() // to silence the warning of not mutating above variable in the case of a type with no references

      
        
      

      return result
  }
}



extension Dog : ConcreteModel {
    static let meowCollection = Meow.database["dog"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<Dog> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }

    static func findOne(matching closure: ((VirtualInstance) -> (Query))) throws -> Dog? {
        let query = closure(VirtualInstance())
        return try self.findOne(matching: query)
    }

    static func count(matching closure: ((VirtualInstance) -> (Query))) throws -> Int {
        let query = closure(VirtualInstance())
        return try self.count(matching: query)
    }
}

extension Dog : StringInitializable {
  public convenience init?(from string: String) throws {
    guard let document = try Dog.meowCollection.findOne(matching: "_id" == (try ObjectId(string))) else {
      return nil
    }

    try self.init(fromDocument: document)
  }
}

extension Dog : ValueConvertible {
  public func makeBSONPrimitive() -> BSONPrimitive {
    return self.meowSerialize()
  }
}

extension Dog : ResponseRepresentable {
  public func makeResponse() -> Response {
    return self.makeExtendedJSON().makeResponse()
  }
}

extension Flat : ConcreteModel {
    static let meowCollection = Meow.database["flat"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<Flat> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }

    static func findOne(matching closure: ((VirtualInstance) -> (Query))) throws -> Flat? {
        let query = closure(VirtualInstance())
        return try self.findOne(matching: query)
    }

    static func count(matching closure: ((VirtualInstance) -> (Query))) throws -> Int {
        let query = closure(VirtualInstance())
        return try self.count(matching: query)
    }
}

extension Flat : StringInitializable {
  public convenience init?(from string: String) throws {
    guard let document = try Flat.meowCollection.findOne(matching: "_id" == (try ObjectId(string))) else {
      return nil
    }

    try self.init(fromDocument: document)
  }
}

extension Flat : ValueConvertible {
  public func makeBSONPrimitive() -> BSONPrimitive {
    return self.meowSerialize()
  }
}

extension Flat : ResponseRepresentable {
  public func makeResponse() -> Response {
    return self.makeExtendedJSON().makeResponse()
  }
}

extension House : ConcreteModel {
    static let meowCollection = Meow.database["house"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<House> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }

    static func findOne(matching closure: ((VirtualInstance) -> (Query))) throws -> House? {
        let query = closure(VirtualInstance())
        return try self.findOne(matching: query)
    }

    static func count(matching closure: ((VirtualInstance) -> (Query))) throws -> Int {
        let query = closure(VirtualInstance())
        return try self.count(matching: query)
    }
}

extension House : StringInitializable {
  public convenience init?(from string: String) throws {
    guard let document = try House.meowCollection.findOne(matching: "_id" == (try ObjectId(string))) else {
      return nil
    }

    try self.init(fromDocument: document)
  }
}

extension House : ValueConvertible {
  public func makeBSONPrimitive() -> BSONPrimitive {
    return self.meowSerialize()
  }
}

extension House : ResponseRepresentable {
  public func makeResponse() -> Response {
    return self.makeExtendedJSON().makeResponse()
  }
}

extension User : ConcreteModel {
    static let meowCollection = Meow.database["user"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<User> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }

    static func findOne(matching closure: ((VirtualInstance) -> (Query))) throws -> User? {
        let query = closure(VirtualInstance())
        return try self.findOne(matching: query)
    }

    static func count(matching closure: ((VirtualInstance) -> (Query))) throws -> Int {
        let query = closure(VirtualInstance())
        return try self.count(matching: query)
    }
}

extension User : StringInitializable {
  public convenience init?(from string: String) throws {
    guard let document = try User.meowCollection.findOne(matching: "_id" == (try ObjectId(string))) else {
      return nil
    }

    try self.init(fromDocument: document)
  }
}

extension User : ValueConvertible {
  public func makeBSONPrimitive() -> BSONPrimitive {
    return self.meowSerialize()
  }
}

extension User : ResponseRepresentable {
  public func makeResponse() -> Response {
    return self.makeExtendedJSON().makeResponse()
  }
}


extension Droplet {
  public func start(_ mongoURL: String) throws -> Never {
    let meow = try Meow.init(mongoURL)

    
      
    
      
    
      
    
      
        
          self.get("users", User.self, "customFieldUpdate") { request, model in
        

        
          
            guard let query = request.query, case .object(let parameters) = query else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let key = parameters["key"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
            

              
                guard let value = parameters["value"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
        

        

        
        // TODO: Reverse isVoid when that works
           try model.customFieldUpdate(
            
              key: key
              
              ,
              
            
              value: value
              
            
          )

            
              return Response(status: .ok)
            
          
          }
      
        
          self.get("users", User.self, "update") { request, model in
        

        
          
            guard let query = request.query, case .object(let parameters) = query else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let email = parameters["email"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
            
              
                let firstName = parameters["firstName"]?.string
              

            
          
            
              
                let lastName = parameters["lastName"]?.string
              

            
          
        

        

        
        // TODO: Reverse isVoid when that works
           try model.update(
            
              email: email
              
              ,
              
            
              firstName: firstName
              
              ,
              
            
              lastName: lastName
              
            
          )

            
              return Response(status: .ok)
            
          
          }
      
        
          self.post("users", "register") { request in
        

        
          
            guard let json = request.json?.node, case .object(let parameters) = json else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let email = parameters["email"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try User.register(
            
              email: email
              
            
          )

          
            return responseObject
          
        
          }
      
        
          self.get("users", User.self, "get") { request, model in
        

        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject =  try model.get(
            
          )

            
              return responseObject
            
          
          }
      
        
          self.get("users", User.self, "dog") { request, model in
        

        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject =  try model.dog(
            
          )

            
              return responseObject
            
          
          }
      
    
    self.run()
  }
}
