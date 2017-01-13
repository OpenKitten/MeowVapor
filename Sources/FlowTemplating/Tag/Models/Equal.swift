import BSON

public final class Equal: BasicTag {
    public enum Error: LeafError {
        case expected2Arguments
    }

    public let name = "equal"

    public func run(arguments: [Argument]) throws -> ValueConvertible? {
        guard arguments.count == 2 else { throw Error.expected2Arguments }
        return nil
    }

    public func shouldRender(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument],
        value: ValueConvertible?
    ) -> Bool {
        return fuzzyEquals(arguments.first?.value, arguments.last?.value)
    }
}

fileprivate func fuzzyEquals(_ lhs: ValueConvertible?, _ rhs: ValueConvertible?) -> Bool {
    let lhs = lhs ?? Null()
    let rhs = rhs ?? Null()

    switch lhs.makeBSONPrimitive() {
    case is Document:
        guard let rhs = rhs.documentValue else { return false }
        return lhs as? Document == rhs
    case is Bool:
        return lhs as? Bool == rhs.boolValue
    case is ObjectId:
        return lhs as? ObjectId == rhs.objectIdValue
    case is Null:
        return rhs is Null
    case is Double, is Int32, is Int64:
        switch rhs {
        case is Double:
            return lhs.double == rhs.double
        case is Int32:
            return lhs.int32 == rhs.int32
        case is Int64:
            return lhs.int64 == rhs.int64
        default:
            return false
        }
    case is String:
        return lhs.string == rhs.string
    default:
        return false
    }
}
