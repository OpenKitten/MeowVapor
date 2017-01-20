//
//  LanguageMustache.swift
//  MeowVapor
//
//  Created by Joannis Orlandos on 20/01/2017.
//
//

import Foundation

public enum LeafSyntax: TemplatingSyntax {
    public enum Error: Swift.Error {
        case nullTerminatorInTemplate
        case tagContainsWhitespace
        case variablePathContainsWhitespace
        case invalidSecondArugmentInLoop
        case unknownTag([UInt8])
        case tagNotOpened
        case tagNotClosed
        case fileDoesNotExist(atPath: String)
    }
    
    public static func compile(atPath path: String) throws -> [UInt8] {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw Error.fileDoesNotExist(atPath: path)
        }
        
        return try LeafSyntax.compile(fromData: try data.makeBytes())
    }
    
    public static func compile(fromData input: [UInt8]) throws -> [UInt8] {
        var position = 0
        var rawBuffer = [UInt8]()
        var compiledTemplate = [UInt8]()
        
        func compileVariablePath(fromData path: [UInt8]) throws -> [UInt8] {
            // " "
            guard !path.contains(0x20) else {
                throw Error.variablePathContainsWhitespace
            }
            
            return path.map { byte in
                // "."->0x00
                return byte == 0x2e ? 0x00 : byte
                // Once for the last key, once for the path
            } + [0x00, 0x00]
        }
        
        func parseTag() throws -> [UInt8] {
            var tagName = [UInt8]()
            
            tagNameLoop: while position < input.count {
                defer { position += 1 }
                
                // " "
                guard input[position] != 0x20 else {
                    throw Error.tagContainsWhitespace
                }
                
                // "("
                if input[position] == 0x28 {
                    break tagNameLoop
                }
                
                tagName.append(input[position])
            }
            
            if tagName == [] {
                var variableBytes = [UInt8]()
                
                variableLoop: while position < input.count {
                    defer { position += 1 }
                    
                    // ")"
                    if input[position] == 0x29 {
                        break variableLoop
                    }
                    
                    variableBytes.append(input[position])
                }
                
                let variablePath = try compileVariablePath(fromData: variableBytes)
                
                return [0x02, 0x03, 0x01] + variablePath
            // "loop"
            } else if tagName == [0x6c, 0x6f, 0x6f, 0x70] {
                var newVariableBytes = [UInt8]()
                var oldVariableBytes = [UInt8]()
                
                variableLoop: while position < input.count {
                    defer { position += 1 }
                    
                    // "," " "
                    if input[position] == 0x2c || input[position] == 0x20 {
                        break variableLoop
                    }
                    
                    oldVariableBytes.append(input[position])
                }
                
                whitespaceLoop: while position < input.count {
                    guard input[position] == 0x2c || input[position] == 0x20 || input[position] == 0x0a || input[position] == 0x22 else {
                        throw Error.invalidSecondArugmentInLoop
                    }
                    
                    defer { position += 1 }
                    
                    if input[position] == 0x22 {
                        break whitespaceLoop
                    }
                }
                
                variableLoop: while position < input.count {
                    defer { position += 1 }
                    
                    // null terminator && "."
                    guard input[position] != 0x00 else {
                        throw Error.nullTerminatorInTemplate
                    }
                    
                    // " (quotation mark)
                    if input[position] == 0x22 {
                        break variableLoop
                    }
                    
                    newVariableBytes.append(input[position])
                }
                
                // ")"
                guard input[position] == 0x29 else {
                    throw Error.invalidSecondArugmentInLoop
                }
                
                var check = false
                var subTemplate = [UInt8]()
                
                startTagLoop: while position < input.count {
                    defer { position += 1 }
                    
                    // "{"
                    if input[position] == 0x7b {
                        check = true
                        break startTagLoop
                    }
                }
                
                guard check else {
                    throw Error.tagNotOpened
                }
                
                check = false
                
                endTagLoop: while position < input.count {
                    defer { position += 1 }
                    
                    // "}"
                    if input[position] == 0x7d {
                        check = true
                        break endTagLoop
                    }
                    
                    subTemplate.append(input[position])
                }
                
                guard check else {
                    throw Error.tagNotClosed
                }
                
                let oldVariablePath = try compileVariablePath(fromData: oldVariableBytes)
                
                let subTemplateCode = try LeafSyntax.compile(fromData: subTemplate)
                
                var compiledLoop: [UInt8] = [0x02, 0x02]
                compiledLoop.append(contentsOf: newVariableBytes)
                compiledLoop.append(0x00)
                compiledLoop.append(0x01)
                compiledLoop.append(contentsOf: oldVariablePath)
                compiledLoop.append(contentsOf: subTemplateCode)
                compiledLoop.append(0x00)
                
                return compiledLoop
            } else {
                throw Error.unknownTag(tagName)
            }
        }
        
        while position < input.count {
            // "#"
            if input[position] == 0x23 {
                if rawBuffer.count > 0 {
                    compiledTemplate.append(0x01)
                    compiledTemplate.append(contentsOf: rawBuffer)
                    compiledTemplate.append(0x00)
                    rawBuffer = []
                }
                
                position += 1
                
                compiledTemplate.append(contentsOf: try parseTag())
            // Null terminator
            } else if input[position] != 0x00 {
                rawBuffer.append(input[position])
                position += 1
            } else {
                throw Error.nullTerminatorInTemplate
            }
        }
        
        if rawBuffer.count > 0 {
            compiledTemplate.append(0x01)
            compiledTemplate.append(contentsOf: rawBuffer)
            compiledTemplate.append(0x00)
            rawBuffer = []
        }
        
        compiledTemplate.append(0x00)
        
        return compiledTemplate
    }
}
