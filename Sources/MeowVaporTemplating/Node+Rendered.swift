import BSON

extension ValueConvertible {
    func rendered() throws -> Bytes {
        switch self.makeBSONPrimitive() {
        case is Document, is Null:
            return []
        case is Bool:
            return self.makeBSONPrimitive().boolValue!.description.bytes
        case is Int32:
            return (self.makeBSONPrimitive() as! Int32).description.bytes
        case is Int64:
            return (self.makeBSONPrimitive() as! Int64).description.bytes
        case is Double:
            return (self.makeBSONPrimitive() as! Double).description.bytes
        case is String:
            // defaults to escaping, use #raw(var) to unescape. 
            return (self.makeBSONPrimitive() as! String).htmlEscaped().bytes
        case is Binary:
            return (self.makeBSONPrimitive() as! Binary).makeBytes()
        case is ObjectId:
            return (self.makeBSONPrimitive() as! ObjectId).hexString.bytes
        default:
            return []
        }
    }
}
