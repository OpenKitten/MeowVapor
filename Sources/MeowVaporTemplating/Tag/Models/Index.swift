import BSON

public class Index: BasicTag {
    public let name = "index"

    public func run(arguments: [Argument]) throws -> ValueConvertible? {
        guard
            arguments.count == 2,
            let array = arguments[0].value?.documentValue?.arrayValue,
            let index = arguments[1].value?.int,
            index < array.count
            else { return nil }
        return array[index]
    }
}
