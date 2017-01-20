import Foundation
import MongoKitten

public enum TemplateError: Error {
    case invalidElement(UInt8)
    case invalidStatement(UInt8)
    case invalidExpression(UInt8)
    case unableToInstantiateString(fromBytes: [UInt8])
    case emptyVariablePath
    case variableNotADocument(atKey: String)
    case loopingOverNil
    case unclosedLoop
    case loopingOverNonArrayType
}

public protocol TemplatingSyntax {
    static func compile(fromData data: [UInt8]) throws -> [UInt8]
}

public protocol ContextValueConvertible {
    func makeContextValue() ->Template.Context.ContextValue
}

public protocol DocumentRepresentable {
    func makeDocument() -> Document
}

extension Document: DocumentRepresentable {
    public func makeDocument() -> Document {
        return self
    }
}

extension Document: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension String: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension Int: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension Int32: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension Int64: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension Bool: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension Date: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}
extension ObjectId: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

extension RegularExpression: ContextValueConvertible {
    public func makeContextValue() -> Template.Context.ContextValue {
        return .value(self)
    }
}

public final class Template {
    let compiled: [UInt8]
    
    public init(compiled data: [UInt8]) {
        self.compiled = data
    }
    
    public init(raw template: String) throws {
        self.compiled = try Template.compile(template)
    }
    
    public struct Context: ExpressibleByDictionaryLiteral {
        public enum ContextValue: ContextValueConvertible {
            case cursor(Cursor<Document>)
            case value(ValueConvertible)
            
            public func makeContextValue() -> ContextValue {
                return self
            }
        }
        
        var context: [String: ContextValue]
        
        public init(dictionaryLiteral elements: (String, ContextValueConvertible)...) {
            var context = [String: ContextValue]()
            
            for (key, value) in elements {
                context[key] = value.makeContextValue()
            }
            
            self.context = context
        }
    }
    
    public func run(inContext context: Context) throws -> [UInt8] {
        var position = 0
        var output = [UInt8]()
        
        func parseCString() throws -> String {
            var stringData = [UInt8]()
            
            while position < compiled.count, compiled[position] != 0x00 {
                defer { position += 1 }
                stringData.append(compiled[position])
            }
            
            position += 1
            
            guard let string = String(bytes: stringData, encoding: String.Encoding.utf8) else {
                throw DeserializationError.unableToInstantiateString(fromBytes: Array(stringData))
            }
            
            return string
        }
        
        func runExpression(inContext context: Context) throws -> Context.ContextValue? {
            switch compiled[position] {
            case 0x01:
                position += 1
                var path = [String]()
                
                while compiled[position] != 0x00 {
                    path.append(try parseCString())
                }
                
                position += 1
                
                guard path.count >= 1 else {
                    throw TemplateError.emptyVariablePath
                }
                
                let firstPart = path.removeFirst()
                
                guard let contextValue = context.context[firstPart] else {
                    throw TemplateError.variableNotADocument(atKey: firstPart)
                }
                
                if case .value(let value) = contextValue {
                    if path.count == 0 {
                        return .value(value)
                    }
                    
                    guard let doc = value as? Document, let value = doc[raw: path] else {
                        return nil
                    }
                    
                    return .value(value)
                }
                
                guard path.count == 0 else {
                    return nil
                    // TODO: discuss: throw error?
                }
                
                return contextValue
            case 0x02:
                position += 1
                return .value(true)
            default:
                throw TemplateError.invalidExpression(compiled[position])
            }
        }
        
        func runStatements(inContext context: Context) throws {
            while position < compiled.count {
                elementSwitch: switch compiled[position] {
                case 0x00:
                    position += 1
                    return
                case 0x01:
                    position += 1
                    
                    loop: while position < compiled.count {
                        defer { position += 1 }
                        
                        if compiled[position] == 0x00 {
                            break loop
                        }
                        
                        output.append(compiled[position])
                    }
                case 0x02:
                    position += 1
                    
                    switch compiled[position] {
                    case 0x01:
                        break
                    case 0x02:
                        position += 1
                        
                        let variableName = try parseCString()
                        guard let contextValue = try runExpression(inContext: context) else {
                            throw TemplateError.loopingOverNil
                        }
                        
                        var newContext = context
                        
                        switch contextValue {
                        case .cursor(let cursor):
                            let oldPosition = position
                            for document in cursor {
                                newContext.context[variableName] = .value(document)
                                position = oldPosition
                                try runStatements(inContext: newContext)
                            }
                        case .value(let value):
                            guard let document = value as? Document, document.validatesAsArray() else {
                                throw TemplateError.loopingOverNonArrayType
                            }
                            
                            let oldPosition = position
                            
                            for (_, value) in document {
                                newContext.context[variableName] = .value(value)
                                position = oldPosition
                                try runStatements(inContext: newContext)
                            }
                        }
                        
                        guard compiled[position] == 0x00 else {
                            throw TemplateError.unclosedLoop
                        }
                        
                        position += 1
                    case 0x03:
                        position += 1
                        
                        guard let contextValue = try runExpression(inContext: context), case .value(let value) = contextValue else {
                            break elementSwitch
                        }
                        
                        output.append(contentsOf: value.makeTemplatingUTF8String())
                    default:
                        throw TemplateError.invalidStatement(compiled[position])
                    }
                default:
                    throw TemplateError.invalidElement(compiled[position])
                }
            }
        }
        
        try runStatements(inContext: context)
        
        return output
    }
    
    private static func compile(_ template: String) throws -> [UInt8] {
        return []
    }
}

extension ValueConvertible {
    func makeTemplatingUTF8String() -> [UInt8] {
        switch self.makeBSONPrimitive() {
        case is String:
            return [UInt8]((self as! String).utf8)
        default:
            return []
        }
    }
}
