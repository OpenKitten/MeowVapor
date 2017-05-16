import HTTP
import Cheetah
import Sessions
import ExtendedJSON

extension Request {
    /// Returns a Cheetah JSONObject from a request if the contents are a JSON Object
    public var jsonObject: JSONObject? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        return try? JSONObject(from: bytes)
    }
    
    /// Returns a Cheetah JSONArray from a request if the contents are a JSON Array
    public var jsonArray: JSONArray? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        return try? JSONArray(from: bytes)
    }
    
    /// Returns a Docuement deserialized from the request's extendedJSON contents
    public var document: Document? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        do {
            return try Document(extendedJSON: bytes)
        } catch {
            return nil
        }
    }
}

extension Document {
    /// Recards a Document with a projection
    public func redacting(_ projection: Projection) -> Document {
        var doc: Document = [
            "_id": self["_id"]
        ]
        
        let projection = projection.makeDocument()
        
        for (key, value) in projection {
            if Bool(value) == true {
                doc[key] = self[key]
            } else {
                doc[key] = nil
            }
        }
        
        return doc
    }
}

extension Model {
    
    func makeApiView() -> Document {
        var document = self.serialize() as Document
        
        for key in Self.Key.all where key.type is BaseModel.Type {
            guard let id = ObjectId(document[key.keyString]["$id"]) else {
                continue
            }
            
            document[key.keyString] = id
        }
        
        return Document(data: document.bytes) // because of BSON key iterator / element position tree bug
    }
    
    static func makeModelDocument(from input: Document) -> Document {
        var document = input
        
        for key in Self.Key.all {
            guard let type = key.type as? BaseModel.Type, let id = ObjectId(document[key.keyString]) else {
                continue
            }
            
            document[key.keyString] = DBRef(referencing: id, inCollection: type.collection)
        }
        
        return document
    }
    
}
