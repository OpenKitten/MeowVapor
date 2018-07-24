import Meow
import Core
import BSON

public enum AutoQueryableModelError: Error {
    case propertyNotFound
}

public extension QueryableModel {
    static func makeQueryPath<T>(for key: KeyPath<Self, T>) throws -> String {
        guard let property = try Self.decodeProperty(forKey: key) else {
            throw AutoQueryableModelError.propertyNotFound
        }
        
        return property.path.joined(separator: ".")
    }
}

extension ObjectId: ReflectionDecodable {
    fileprivate static func leftDecoded() throws -> ObjectId {
        return try ObjectId("000000000000000000000000")
    }
    
    fileprivate static func rightDecoded() throws -> ObjectId {
        return try ObjectId("ffffffffffffffffffffffff")
    }
    
    public static func reflectDecoded() throws -> (ObjectId, ObjectId) {
        return try (leftDecoded(), rightDecoded())
    }
    
    public static func reflectDecodedIsLeft(_ item: ObjectId) throws -> Bool {
        return try leftDecoded() == item
    }
}

extension Document: ReflectionDecodable {
    fileprivate static func leftDecoded() throws -> Document {
        return ["left": 1]
    }
    
    fileprivate static func rightDecoded() throws -> Document {
        return ["right": 1]
    }
    
    public static func reflectDecoded() throws -> (Document, Document) {
        return try (leftDecoded(), rightDecoded())
    }
    
    public static func reflectDecodedIsLeft(_ item: Document) throws -> Bool {
        return try leftDecoded() == item
    }
}

extension Reference: AnyReflectionDecodable where M.Identifier == ObjectId {}
extension Reference: ReflectionDecodable where M.Identifier == ObjectId {
    private static func leftDecoded() throws -> Reference<M> {
        return try Reference(unsafeTo: ObjectId.leftDecoded())
    }
    
    private static func rightDecoded() throws -> Reference<M> {
        return try Reference(unsafeTo: ObjectId.rightDecoded())
    }
    
    public static func reflectDecoded() throws -> (Reference<M>, Reference<M>) {
        return try (leftDecoded(), rightDecoded())
    }
}

extension Set: ReflectionDecodable, AnyReflectionDecodable where Element: ReflectionDecodable {
    public static func reflectDecoded() throws -> (Set<Element>, Set<Element>) {
        let elements = try Element.reflectDecoded()
        return ([elements.0], [elements.1])
    }
}
