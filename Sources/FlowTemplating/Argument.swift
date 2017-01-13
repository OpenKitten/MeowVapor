import BSON

/**
    Concrete representation of a parameter
*/
public enum Argument {
    /**
        - parameter path: path declared for variable
        - parameter value: found value in given scope
    */
    case variable(path: [String], value: ValueConvertible?)

    /**
        - parameter value: the value for a given constant. Declared w/ `""`
    */
    case constant(value: String)
}

extension Argument {
    public var value: ValueConvertible? {
        switch self {
        case let .constant(value: value):
            return value
        case let .variable(path: _, value: value):
            return value
        }
    }
}
