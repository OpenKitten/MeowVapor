import Foundation
import struct Cheetah.JSONObject
import struct Cheetah.JSONArray
import protocol Cheetah.Value
import BSON
import Meow
import struct JSON.JSON
import Node

extension ObjectId {
    /// Creates an ObjectId from JSON
    public init?(_ jsonValue: Cheetah.Value?) {
        guard let string = String(jsonValue), let id = try? ObjectId(string) else {
            return nil
        }
        
        self = id
    }
}

extension JSONObject : JSONRepresentable {}
extension JSONArray : JSONRepresentable {}

extension Value {
    public func makeJSON() throws -> JSON {
        switch self {
        case let string as String:
            return JSON(.string(string))
        case let int as Int:
            return JSON(.number(.int(int)))
        case let double as Double:
            return JSON(.number(.double(double)))
        case _ as NSNull:
            return JSON(.null)
        case let bool as Bool:
            return JSON(.bool(bool))
        case let object as JSONObject:
            var dict = [String: StructuredData]()
            
            for (key, value) in object {
                dict[key] = try value.makeJSON().wrapped
            }
            
            return JSON(.object(dict))
        case let array as JSONArray:
            let jsonArray = try array.map { try $0.makeJSON().wrapped }
            
            return JSON(.array(jsonArray))
        default:
            throw JSONConversionError()
        }
    }
}

public struct JSONConversionError : Error {}
