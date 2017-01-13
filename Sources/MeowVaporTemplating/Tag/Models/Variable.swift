public final class Variable: Tag {
    public enum Error: LeafError {
        case expectedOneArgument
    }

    public let name = "" // empty name, ie: *(variable)

    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]) throws -> ValueConvertible? {
        // temporary escaping mechanism. 
        // ALL tags are interpreted, use `*()` to have an empty `*` rendered
        if arguments.isEmpty { return [TOKEN].string }
        guard arguments.count == 1 else { throw Error.expectedOneArgument }
        return arguments[0].value
    }
}
