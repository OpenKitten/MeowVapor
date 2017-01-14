import HTTP
import MongoKitten

extension Cursor: ValueConvertible {
    public func makeBSONPrimitive() -> BSONPrimitive {
        return Document(array: Array(self).flatMap {
            $0 as? ValueConvertible
        })
    }
}

extension Cursor: ResponseRepresentable {
    public func makeResponse() -> Response {
        return Document(array: Array(self).flatMap {
                $0 as? ValueConvertible
            }).makeExtendedJSON().makeResponse()
    }
}
