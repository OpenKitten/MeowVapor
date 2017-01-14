// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import HTTP
import Vapor
import Foundation
import MeowVapor




  
    // Optional(String)
    extension Difficulty : ConcreteSingleValueSerializable {
      init(value: ValueConvertible) throws {
        let value: String = try Meow.Helpers.requireValue(value.makeBSONPrimitive() as? String, keyForError: "")
        let me: Difficulty = try Meow.Helpers.requireValue(Difficulty(rawValue: value), keyForError: "")

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
  

  
    // Optional(String)
    extension Medium : ConcreteSingleValueSerializable {
      init(value: ValueConvertible) throws {
        let value: String = try Meow.Helpers.requireValue(value.makeBSONPrimitive() as? String, keyForError: "")
        let me: Medium = try Meow.Helpers.requireValue(Medium(rawValue: value), keyForError: "")

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
  



extension Tutorial : ConcreteSerializable {
  func meowSerialize() -> Document {
    
      var doc: Document = ["_id": self.id]
    

    

    
      // id: ObjectId (ObjectId)
      
        
      
    
      // name: String (String)
      
        
          doc["name"] = self.name
        
      
    
      // author: String (String)
      
        
          doc["author"] = self.author
        
      
    
      // medium: Medium (Medium)
      
        
          doc[raw: "medium"] = self.medium.meowSerialize()
        
      
    
      // image: String (String)
      
        
          doc["image"] = self.image
        
      
    
      // url: String (String)
      
        
          doc["url"] = self.url
        
      
    
      // description: String (String)
      
        
          doc["description"] = self.description
        
      
    
      // duration: Int (Int)
      
        
          doc["duration"] = self.duration
        
      
    
      // difficulty: Difficulty (Difficulty)
      
        
          doc[raw: "difficulty"] = self.difficulty.meowSerialize()
        
      
    
      // exists: Bool (Bool)
      
        
          doc["exists"] = self.exists
        
      
    

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
             
          
      
     
        // loop: author

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let authorValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "author") as? String, keyForError: "author")
             
          
      
     
        // loop: medium

        
          
          
              
                let MediumVal = try Meow.Helpers.requireValue(source.removeValue(forKey: "medium"), keyForError: "medium")
                let mediumValue: Medium = try Medium(value: MediumVal)
              
          
        
      
     
        // loop: image

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let imageValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "image") as? String, keyForError: "image")
             
          
      
     
        // loop: url

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let urlValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "url") as? String, keyForError: "url")
             
          
      
     
        // loop: description

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let descriptionValue: String = try Meow.Helpers.requireValue(source.removeValue(forKey: "description") as? String, keyForError: "description")
             
          
      
     
        // loop: duration

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let durationValue: Int = try Meow.Helpers.requireValue(source.removeValue(forKey: "duration") as? Int, keyForError: "duration")
             
          
      
     
        // loop: difficulty

        
          
          
              
                let DifficultyVal = try Meow.Helpers.requireValue(source.removeValue(forKey: "difficulty"), keyForError: "difficulty")
                let difficultyValue: Difficulty = try Difficulty(value: DifficultyVal)
              
          
        
      
     
        // loop: exists

        
          
             // The property is a BSON type, so we can just extract it from the document:
             
                  let existsValue: Bool = try Meow.Helpers.requireValue(source.removeValue(forKey: "exists") as? Bool, keyForError: "exists")
             
          
      
     

      // initializerkaas:
      try self.init(
        
        
          named: nameValue
          
          ,
          
        
          author: authorValue
          
          ,
          
        
          url: urlValue
          
          ,
          
        
          image: imageValue
          
        
      )

      
        
          self.id = idValue
        
      
        
          self.name = nameValue
        
      
        
          self.author = authorValue
        
      
        
          self.medium = mediumValue
        
      
        
          self.image = imageValue
        
      
        
          self.url = urlValue
        
      
        
          self.description = descriptionValue
        
      
        
          self.duration = durationValue
        
      
        
          self.difficulty = difficultyValue
        
      
        
          self.exists = existsValue
        
      
  }

  struct VirtualInstance {
    var keyPrefix: String

    
      // id: ObjectId
      
        var id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "id") }
      
    
      // name: String
      
        var name: VirtualString { return VirtualString(name: keyPrefix + "name") }
      
    
      // author: String
      
        var author: VirtualString { return VirtualString(name: keyPrefix + "author") }
      
    
      // medium: Medium
      
        var medium: Medium.VirtualInstance { return Medium.VirtualInstance(keyPrefix: "medium.") }
      
    
      // image: String
      
        var image: VirtualString { return VirtualString(name: keyPrefix + "image") }
      
    
      // url: String
      
        var url: VirtualString { return VirtualString(name: keyPrefix + "url") }
      
    
      // description: String
      
        var description: VirtualString { return VirtualString(name: keyPrefix + "description") }
      
    
      // duration: Int
      
        var duration: VirtualNumber { return VirtualNumber(name: keyPrefix + "duration") }
      
    
      // difficulty: Difficulty
      
        var difficulty: Difficulty.VirtualInstance { return Difficulty.VirtualInstance(keyPrefix: "difficulty.") }
      
    
      // exists: Bool
      
        var exists: VirtualBool { return VirtualBool(name: keyPrefix + "exists") }
      
    

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



extension Tutorial : ConcreteModel {
    static let meowCollection = Meow.database["tutorial"]

    static func find(matching closure: ((VirtualInstance) -> (Query))) throws -> Cursor<Tutorial> {
        let query = closure(VirtualInstance())
        return try self.find(matching: query)
    }

    static func findOne(matching closure: ((VirtualInstance) -> (Query))) throws -> Tutorial? {
        let query = closure(VirtualInstance())
        return try self.findOne(matching: query)
    }

    static func count(matching closure: ((VirtualInstance) -> (Query))) throws -> Int {
        let query = closure(VirtualInstance())
        return try self.count(matching: query)
    }
}

extension Tutorial : StringInitializable {
  public convenience init?(from string: String) throws {
    guard let document = try Tutorial.meowCollection.findOne(matching: "_id" == (try ObjectId(string))) else {
      return nil
    }

    try self.init(fromDocument: document)
  }
}

extension Tutorial : ValueConvertible {
  public func makeBSONPrimitive() -> BSONPrimitive {
    return self.meowSerialize()
  }
}

extension Tutorial : ResponseRepresentable {
  public func makeResponse() -> Response {
    return self.makeExtendedJSON().makeResponse()
  }
}


extension Droplet {
  public func start(_ mongoURL: String) throws -> Never {
    let meow = try Meow.init(mongoURL)

    
      
        
          self.get("tutorials", "/") { request in
        

        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try Tutorial.list(
            
          )

          
            return responseObject
          
        
          }
      
        
          self.get("tutorials", "filtered") { request in
        

        
          
            guard let query = request.query, case .object(let parameters) = query else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let minDuration = parameters["minDuration"]?.int else {
                  return Response(status: .badRequest)
                }
              
            
          
            

              
                guard let maxDuration = parameters["maxDuration"]?.int else {
                  return Response(status: .badRequest)
                }
              
            
          
        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try Tutorial.list(
            
              minDuration: minDuration
              
              ,
              
            
              maxDuration: maxDuration
              
            
          )

          
            return responseObject
          
        
          }
      
        
          self.post("tutorials", "/") { request in
        

        
          
            guard let json = request.json?.node, case .object(let parameters) = json else {
                return Response(status: .badRequest)
            }
          

          
            

              
                guard let name = parameters["name"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
            

              
                guard let author = parameters["author"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
            

              
                guard let url = parameters["url"]?.string else {
                  return Response(status: .badRequest)
                }
              
            
          
            
              
                let image = parameters["image"]?.string
              

            
          
        

        

        
        // TODO: Reverse isVoid when that works
           let responseObject = try Tutorial.create(
            
              name: name
              
              ,
              
            
              author: author
              
              ,
              
            
              url: url
              
              ,
              
            
              image: image
              
            
          )

          
            return responseObject
          
        
          }
      
        
          self.delete("tutorials", Tutorial.self, "/") { request, model in
        

        

        

        
        // TODO: Reverse isVoid when that works
           try model.remove(
            
          )

            
              return Response(status: .ok)
            
          
          }
      
    
    self.run()
  }
}
