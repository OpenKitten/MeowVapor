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
