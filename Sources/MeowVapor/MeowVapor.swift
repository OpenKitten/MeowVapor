import HTTP
import Cheetah
import Sessions
import ExtendedJSON

extension Request {
    public var jsonObject: JSONObject? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        return try? JSONObject(from: bytes)
    }
    
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
