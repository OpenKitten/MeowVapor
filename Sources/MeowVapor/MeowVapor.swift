import Meow
import Vapor
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
    
    public var jsonValue: Value? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        return try? Cheetah.JSON.parse(from: bytes)
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

extension Meow.Error: Debuggable {
    
    public var reason: String {
        switch self {
        case .missingOrInvalidValue(let key, let expected, _): return "Missing or invalid value for \(key), expected \(expected)"
        case .invalidValue(let key, let reason): return "Invalid value for \(key): \(reason)"
        case .referenceError(let id, let type): return "Invalid reference to \(type) \(id)"
        case .undeletableObject(let reason): return "Could not delete object: \(reason)"
        case .enumCaseNotFound(let `enum`, let name): return "Enum case \(name) not found on \(`enum`)"
        case .fileTooLarge(let size, let max): return "Could not store file because its size (\(size)) exceeds the maximum size (\(max))"
        case .cannotDeserialize(let type, _, let expectedPrimitive): return "Could not deserialize \(type) - expected \(expectedPrimitive)"
        case .brokenReference(_): return "The reference is invalid"
        case .infiniteReferenceLoop(let type, let id): return "An infinite reference loop (to \(type) \(id)) has occurred while trying to deserialize an object. This happens if objects are referenced like this: `a` -> `b` -> `a`."
        case .brokenFileReference(let id): return "Could not resolve file reference \(id)"
        default: return "Unknown error"
        }
    }
    
    public var possibleCauses: [String] {
        switch self {
        case .invalidValue, .missingOrInvalidValue: return ["The source data is invalid"]
        case .referenceError: return ["The referenced object was deleted"]
        default: return ["Unknown"]
        }
    }
    
    public var suggestedFixes: [String] {
        return []
    }
    
    public var identifier: String {
        return "Meow.Error"
    }
    
}
