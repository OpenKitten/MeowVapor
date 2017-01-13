import BSON

public final class Export: BasicTag {
    public let name = "export"
    public func run(arguments: [Argument]) throws -> ValueConvertible? { return nil }
}
