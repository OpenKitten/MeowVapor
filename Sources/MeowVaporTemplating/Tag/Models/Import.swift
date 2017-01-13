import BSON

public final class Import: BasicTag {
    public let name = "import"
    public func run(arguments: [Argument]) throws -> ValueConvertible? { return nil }
}
