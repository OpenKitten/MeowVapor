// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import HTTP
import Vapor
import Foundation
import MeowVapor






  
    // Optional(String)
    extension Gender : ConcreteSingleValueSerializable {
      init(value: ValueConvertible) throws {
        let value: String = try Meow.Helpers.requireValue(value.makeBSONPrimitive() as? String, keyForError: "")
        let me: Gender = try Meow.Helpers.requireValue(Gender(rawValue: value), keyForError: "")

        self = me
      }

      func meowSerialize() -> ValueConvertible {
        return self.rawValue
      }

      struct VirtualInstance {
        var keyPrefix: String

        

        init(keyPrefix: String = "") {
          self.keyPrefix = keyPrefix
        }
      }
    }
  



extension User : ConcreteSerializable {
  func meowSerialize() -> Document {
    
      var doc: Document = ["_id": self.id]
    

    

    
      // id: ObjectId (ObjectId)
      
        
      
    
      // username: String (String)
      
        
          doc["username"] = self.username
        
      
    
      // password: String (String)
      
        
          doc["password"] = self.password
        
      
    
      // age: Int? (Int)
      
        
          doc["age"] = self.age
        
      
    
      // gender: Gender? (Gender)
      
        
          doc[raw: "gender"] = self.gender?.meowSerialize()
        
      
    
      // details: Details? (Details)
      
        
          doc[raw: "details"] = self.details?.meowSerialize()
        
      
    

    return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
      
        
        // loop: id

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        
        // loop: username

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let usernameValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "username") as? String, keyForError: "username")
             
          
      
     
        
        // loop: password

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let passwordValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "password") as? String, keyForError: "password")
             
          
      
     
        
        // loop: age

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let ageValue: Int? = source.removeValue(forKey: "age") as? Int
             
          
      
     
        
        // loop: gender

        
          
          
              let genderValue: Gender?
              
                  if let sourceVal = source.removeValue(forKey: "gender") {
                    genderValue = try Gender(value: sourceVal)
                  } else {
                    genderValue = nil
                  }
                
          
        
      
     
        
        // loop: details

        
          
          
              let detailsValue: Details?
              

                if let detailsDocument: Document = source.removeValue(forKey: "details") as? Document {
                  detailsValue = try Details(fromDocument: detailsDocument)
                } else {
                  detailsValue = nil
                }
              
          
        
      
     

      // initializerkaas:
      try self.init(
        
        
          username: usernameValue
          
          ,
          
        
          password: passwordValue
          
        
      )

      
      
        
        
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
    

    

    
      // firstName: String? (String)
      
        
          doc["firstName"] = self.firstName
        
      
    
      // lastName: String? (String)
      
        
          doc["lastName"] = self.lastName
        
      
    

    return doc
  }

  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
      
        
        // loop: firstName

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let firstNameValue: String? = source.removeValue(forKey: "firstName") as? String
             
          
      
     
        
        // loop: lastName

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let lastNameValue: String? = source.removeValue(forKey: "lastName") as? String
             
          
      
     

      // initializerkaas:
      try self.init(
        
        
      )

      
      
        
        
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
