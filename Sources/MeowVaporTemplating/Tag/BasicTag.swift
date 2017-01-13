public protocol BasicTag: Tag {
    func run(arguments: [Argument]) throws -> ValueConvertible?
}

extension BasicTag {
    public func run(
        stem: Stem,
        context: Context,
        tagTemplate: TagTemplate,
        arguments: [Argument]
        ) throws -> ValueConvertible? {
        return try run(arguments: arguments)
    }
}
