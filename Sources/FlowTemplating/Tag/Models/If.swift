public final class If: Tag {
    public enum Error: LeafError {
        case expectedSingleArgument(have: [Argument])
    }

    public let name = "if"

    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]) throws -> ValueConvertible? {
        guard arguments.count == 1 else { throw Error.expectedSingleArgument(have: arguments) }
        return nil
    }

    public func shouldRender(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument],
        value: ValueConvertible?) -> Bool {
        guard let value = arguments.first?.value else { return false }
        // Existence of bool, evaluate bool.
        if let bool = value.boolValue { return bool }
        // Empty string value returns false.
        if value.string == "" { return false }
        // Otherwise, not-nil returns true.
        return true
    }
}
