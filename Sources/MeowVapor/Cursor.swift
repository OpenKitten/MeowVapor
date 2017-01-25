import HTTP
import MongoKitten

/// Converts a Cursor to an array document. Not efficient, but it works
extension Cursor: ValueConvertible {
    public func makeBSONPrimitive() -> BSONPrimitive {
        return Document(array: Array(self).flatMap {
            $0 as? ValueConvertible
        })
    }
}

/// Makes a cursor responserepresentable, allowing you to output a cursor as a extendedJSON response 
extension Cursor: ResponseRepresentable {
    public func makeResponse() -> Response {
        return Document(array: Array(self).flatMap {
                $0 as? ValueConvertible
            }).makeExtendedJSON().makeResponse()
    }
}
