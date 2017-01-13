import MongoKitten

extension Cursor: ValueConvertible {
    public func makeBSONPrimitive() -> BSONPrimitive {
        return Document(array: Array(self).flatMap {
            $0 as? ValueConvertible
        })
    }
}
