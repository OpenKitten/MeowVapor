import BSON

public final class Else: Tag {
    public let name = "else"
    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]) throws -> ValueConvertible? {
        return nil
    }
    public func shouldRender(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument],
        value: ValueConvertible?) -> Bool {
        return true
    }
}
