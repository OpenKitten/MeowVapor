// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import HTTP
import Vapor
import Foundation
import MeowVapor






  extension Gender : ConcreteSingleValueSerializable {
    
    init(value: ValueConvertible) throws {
      let value: String = try Meow.Helpers.requireValue(value.makeBSONPrimitive() as? String, keyForError: "")
      let me: Gender = try Meow.Helpers.requireValue(Gender(rawValue: value), keyForError: "")

      self = me
    }

    
    func meowSerialize() -> ValueConvertible {
      return self.rawValue
    }

    
    func meowSerialize(resolvingReferences: Bool = false) throws -> ValueConvertible {
      return self.rawValue
    }

    
    struct VirtualInstance {
      
      static func ==(lhs: VirtualInstance, rhs: Gender) -> Query {
        return lhs.keyPrefix == rhs.meowSerialize()
      }

      var keyPrefix: String

      init(keyPrefix: String = "") {
        self.keyPrefix = keyPrefix
      }
    }
  }



extension User : ConcreteSerializable {
  func meowSerialize() -> Document {
    
      var doc: Document = ["_id": self.id]
    

    

    
          doc["username"] = self.username
        
          doc["password"] = self.password
        
          doc["age"] = self.age
        
          doc[raw: "gender"] = self.gender?.meowSerialize()
        
          doc[raw: "details"] = self.details?.meowSerialize()
        

    return doc
  }

  func meowSerialize(resolvingReferences: Bool) throws -> Document {
    
      var doc: Document = ["_id": self.id]
    

    

    
          doc["username"] = self.username
        
          doc["password"] = self.password
        
          doc["age"] = self.age
        
          doc[raw: "gender"] = self.gender?.meowSerialize()
        
          doc[raw: "details"] = self.details?.meowSerialize()
        

    return doc
  }

  
  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
      
        

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let usernameValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "username") as? String, keyForError: "username")
             
          
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let passwordValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "password") as? String, keyForError: "password")
             
          
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let ageValue: Int? = source.removeValue(forKey: "age") as? Int
             
          
      
     
        

        
          
          
              let genderValue: Gender?
              
                  if let sourceVal = source.removeValue(forKey: "gender") {
                    genderValue = try Gender(value: sourceVal)
                  } else {
                    genderValue = nil
                  }
                
          
        
      
     
        

        
          
          
              let detailsValue: Details?
              

                if let detailsDocument: Document = source.removeValue(forKey: "details") as? Document {
                  detailsValue = try Details(fromDocument: detailsDocument)
                } else {
                  detailsValue = nil
                }
              
          
        
      
     

      // Uses the first existing initializer
      // TODO: Support multiple/more complex initializers
      try self.init(
        
        
          username: usernameValue
          
          ,
          
        
          password: passwordValue
          
        
      )

      // Sets the other variables
      
      
        
        
          self.id = idValue
        
      
        
        
          self.username = usernameValue
        
      
        
        
          self.password = passwordValue
        
      
        
        
          self.age = ageValue
        
      
        
        
          self.gender = genderValue
        
      
        
        
          self.details = detailsValue
        
      
  }

  
  struct VirtualInstance {
    var keyPrefix: String

    
    
      
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      
      // username: String
      
        var username: VirtualString { return VirtualString(name: keyPrefix + "username") }
      
    
      
      // password: String
      
        var password: VirtualString { return VirtualString(name: keyPrefix + "password") }
      
    
      
      // age: Int?
      
        var age: VirtualNumber { return VirtualNumber(name: keyPrefix + "age") }
      
    
      
      // gender: Gender?
      
        var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: "gender.") }
      
    
      
      // details: Details?
      
        var details: Details.VirtualInstance { return Details.VirtualInstance(keyPrefix: "details.") }
      
    

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

extension Details : ConcreteSerializable {
  func meowSerialize() -> Document {
    
    var doc = Document()
    

    

    
          doc["firstName"] = self.firstName
        
          doc["lastName"] = self.lastName
        

    return doc
  }

  func meowSerialize(resolvingReferences: Bool) throws -> Document {
    
    var doc = Document()
    

    

    
          doc["firstName"] = self.firstName
        
          doc["lastName"] = self.lastName
        

    return doc
  }

  
  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
      
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let firstNameValue: String? = source.removeValue(forKey: "firstName") as? String
             
          
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let lastNameValue: String? = source.removeValue(forKey: "lastName") as? String
             
          
      
     

      // Uses the first existing initializer
      // TODO: Support multiple/more complex initializers
      try self.init(
        
        
      )

      // Sets the other variables
      
      
        
        
          self.firstName = firstNameValue
        
      
        
        
          self.lastName = lastNameValue
        
      
  }

  
  struct VirtualInstance {
    var keyPrefix: String

    
    
      
      // firstName: String?
      
        var firstName: VirtualString { return VirtualString(name: keyPrefix + "firstName") }
      
    
      
      // lastName: String?
      
        var lastName: VirtualString { return VirtualString(name: keyPrefix + "lastName") }
      
    

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

      static func createIndex(named name: String? = nil, withParameters closure: ((VirtualInstance, IndexSubject) -> ())) throws {
        let indexSubject = IndexSubject()
        closure(VirtualInstance(), indexSubject)

        try meowCollection.createIndexes([(name: name ?? "", parameters: indexSubject.makeIndexParameters())])
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

    
      
    
    self.run()
  }
}
