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
    

    

    
          doc["email"] = self.email
        
          doc["name"] = self.name
        
          doc[raw: "gender"] = self.gender?.meowSerialize()
        
          doc["favouriteNumbers"] = self.favouriteNumbers
        

    return doc
  }

  
  convenience init(fromDocument source: Document) throws {
    var source = source
      // Extract all properties
      
      
        

        
          
            let idValue: ObjectId = try Meow.Helpers.requireValue(source.removeValue(forKey: "_id") as? ObjectId, keyForError: "id")
        
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let emailValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "email") as? String, keyForError: "email")
             
          
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let nameValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "name") as? String, keyForError: "name")
             
          
      
     
        

        
          
          
              let genderValue: Gender?
              
                  if let sourceVal = source.removeValue(forKey: "gender") {
                    genderValue = try Gender(value: sourceVal)
                  } else {
                    genderValue = nil
                  }
                
          
        
      
     
        

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let favouriteNumbersValue: [Int] = try Meow.Helpers.requireValue(source.removeValue(forKey: "favouriteNumbers") as? [Int], keyForError: "favouriteNumbers")
             
          
        
     

      // Uses the first existing initializer
      // TODO: Support multiple/more complex initializers
      try self.init(
        
        
          email: emailValue
          
          ,
          
        
          name: nameValue
          
          ,
          
        
          gender: genderValue
          
        
      )

      // Sets the other variables
      
      
        
        
          self.id = idValue
        
      
        
        
          self.email = emailValue
        
      
        
        
          self.name = nameValue
        
      
        
        
          self.gender = genderValue
        
      
        
        
          self.favouriteNumbers = favouriteNumbersValue
        
      
  }

  
  struct VirtualInstance {
    var keyPrefix: String

    
    
      
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      
      // email: String
      
        var email: VirtualString { return VirtualString(name: keyPrefix + "email") }
      
    
      
      // name: String
      
        var name: VirtualString { return VirtualString(name: keyPrefix + "name") }
      
    
      
      // gender: Gender?
      
        var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: "gender.") }
      
    
      
      // favouriteNumbers: [Int]
      
        var favouriteNumbers: VirtualArray<VirtualNumber> { return VirtualArray<VirtualNumber>(name: keyPrefix + "favouriteNumbers") }
      
    

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

    
      
        
          self.get("users", "/") { request in
        

        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try User.list(
            
          )

          
            
              return responseObject
            
          
        
          }
      
        
          self.get("users", "filtered") { request in
        

        
          
            guard let query = request.query, case .object(let parameters) = query else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let email = parameters["email"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try User.find(
            
              email: email
              
            
          )

          
            
              return try Meow.Helpers.requireValue(responseObject, keyForError: "")
            
          
        
          }
      
        
          self.get("users", "containing") { request in
        

        
          
            guard let query = request.query, case .object(let parameters) = query else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let email = parameters["email"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try User.find(
            
              email: email
              
            
          )

          
            
              return try Meow.Helpers.requireValue(responseObject, keyForError: "")
            
          
        
          }
      
        
          self.delete("users", User.self, "/") { request, model in
        

        

        

        
        // TODO: Reverse isVoid when that works
           try model.remove(
            
          )

            
              return Response(status: .ok)
            
          
          }
      
    
    self.run()
  }
}
