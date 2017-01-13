import BSON

final class Raw: Tag {
    let name = "raw"

    func compileBody(stem: Stem, raw: String) throws -> Leaf {
        let component = Leaf.Component.raw(raw.bytes)
        return Leaf(raw: raw, components: [component])
    }

    func run(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument]) throws -> ValueConvertible? {
        guard let string = arguments.first?.value?.string else { return nil }
        let unescaped = string.bytes
        return Binary(data: unescaped, withSubtype: .generic)
    }

    func shouldRender(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument], value: ValueConvertible?) -> Bool {
        return true
    }
}
