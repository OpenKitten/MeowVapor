import Foundation
import struct Cheetah.JSONObject
import struct Cheetah.JSONArray
import protocol Cheetah.Value
import JSON

enum CheetahJSONError : Error {
    case notAnObject
    case unsupported
}

extension JSONObject : JSONConvertible {
    public init(json: JSON) throws {
        guard let object = try json.wrapped.makeCheetahValue() as? JSONObject else {
            throw CheetahJSONError.notAnObject
        }
        
        self = object
    }
}

extension JSONArray : JSONConvertible {
    public init(json: JSON) throws {
        guard let object = try json.wrapped.makeCheetahValue() as? JSONArray else {
            throw CheetahJSONError.notAnObject
        }
        
        self = object
    }
}

extension StructuredData {
    public func makeCheetahValue() throws -> Cheetah.Value {
        switch self {
        case .null:
            return NSNull()
        case .bool(let bool):
            return bool
        case .number(let number):
            switch number {
            case .double(let d):
                return d
            case .int(let i):
                return i
            case .uint(_):
                throw CheetahJSONError.unsupported
            }
        case .string(let s):
            return s
        case .array(let values):
            return JSONArray(try values.flatMap { try $0.makeCheetahValue() })
        case .object(let pairs):
            var jsonObject = [String: Value]()
            
            for (key, value) in pairs {
                jsonObject[key] = try value.makeCheetahValue()
            }
            
            return JSONObject(jsonObject)
        case .bytes(_):
            throw CheetahJSONError.unsupported
        case .date(_):
            throw CheetahJSONError.unsupported
        }
    }
}
