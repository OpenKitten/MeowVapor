//
//  Pagination.swift
//  Tikcit
//
//  Created by Robbert Brandsma on 10-05-17.
//
//

import Foundation
import Meow
import Vapor
import HTTP
import MongoKitten
import BSON

extension Model {
    public static func paginatedFind(
        for request: Request,
        baseQuery: MongoKitten.Query = Query(Document()),
        allowFiltering filterFields: Set<Self.Key> = [],
        allowSorting sortFields: Set<Self.Key> = [],
        maximumPerPage: Int = 1000
        ) throws -> PaginatedFindResult {
        
        var perPage: Int = try request.query?.get("per_page") ?? maximumPerPage
        let page: Int = try request.query?.get("page") ?? 1
        let sortSpecification = (try request.query?.get("sort") as String?) ?? ""
        let filterSpecification = (try request.query?.get("filter") as String?) ?? ""
        
        if perPage > maximumPerPage {
            perPage = maximumPerPage
        }
        
        let finalQuery = try parseFilterString(filterSpecification, fields: filterFields) && baseQuery
        let finalSort: Sort? = parseSortString(sortSpecification, fields: sortFields)
        
        return try Self.paginatedFind(finalQuery,
                                  sortedBy: finalSort,
                                  page: page,
                                  perPage: perPage)
    }
    
    private static func parseSortString(_ spec: String, fields: Set<Self.Key>) -> Sort? {
        let fieldKeys = fields.map { $0.keyString }
        var sortDocument = Document()
        
        for sort in spec.components(separatedBy: ",") where !sort.isEmpty {
            let pieces = sort.components(separatedBy: "|")
            
            guard pieces.count == 2, !pieces[0].isEmpty else {
                continue
            }
            
            let key = pieces[0]
            
            guard fieldKeys.contains(key) else {
                continue
            }
            
            let method = pieces[1].lowercased()
            
            if method == "asc" {
                sortDocument[key] = Int32(1)
            } else if method == "desc" {
                sortDocument[key] = Int32(-1)
            } else {
                continue
            }
        }
        
        return sortDocument.count > 0 ? Sort(sortDocument.flattened()) : nil
    }
    
    private static func parseFilterString(_ spec: String, fields: Set<Self.Key>) throws -> Query {
        var filterDocument = Document()
        
        // Filter conditions are separated by commas, so we'll split them and loop through them
        for condition in spec.components(separatedBy: ",") where !condition.isEmpty {
            let pieces = condition.components(separatedBy: " ")
            
            guard pieces.count >= 3, !pieces[0].isEmpty, !pieces[1].isEmpty, !pieces[2].isEmpty else {
                continue
            }
            
            let key = pieces[0]
            let op = pieces[1]
            let queryValue = pieces[2..<pieces.endIndex].joined()
            
            guard let type = fields.first(where: { $0.keyString == key })?.type else {
                throw FilterError.unfilterableField(key)
            }
            
            switch op {
            case "cont":
                var unquotedInput = queryValue
                guard unquotedInput.characters.removeFirst() == "'" && unquotedInput.characters.removeLast() == "'" else {
                    throw FilterError.unquotedString
                }
                filterDocument[key] = BSON.RegularExpression(pattern: Foundation.NSRegularExpression.escapedPattern(for: unquotedInput), options: .caseInsensitive)
            default:
                // A 1:1 mapping from our operators to MongoDB operators
                let availableOperators = [
                    "eq": "eq",
                    "ne": "ne",
                    "gt": "gt",
                    "gte": "gte",
                    "lt": "lt",
                    "lte": "lte",
                    "in": "in",
                    "nin": "nin"
                ]
                
                guard let filterOperator = availableOperators[op.lowercased()] else {
                    throw FilterError.invalidOperator(op)
                }
                
                let value: BSON.Primitive
                var inputValue = queryValue
                
                switch type {
                case is Double.Type:
                    guard let double = Double(inputValue) else {
                        throw FilterError.typeError
                    }
                    
                    value = double
                case is Int32.Type, is Int64.Type:
                    guard let int = Int(inputValue) else {
                        throw FilterError.typeError
                    }
                    
                    value = int
                case is Date.Type:
                    guard let timestamp = Double(inputValue) else {
                        throw FilterError.typeError
                    }
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    value = date
                case is String.Type:
                    guard inputValue.characters.count >= 2 else {
                        throw FilterError.typeError
                    }
                    
                    guard inputValue.characters.removeFirst() == "'" && inputValue.characters.removeLast() == "'" else {
                        throw FilterError.unquotedString
                    }
                    
                    value = inputValue
                case is Bool.Type:
                    switch inputValue {
                    case "true": value = true
                    case "false": value = false
                    default: throw FilterError.typeError
                    }
                case is ObjectId.Type:
                    guard let id = try? ObjectId(inputValue) else {
                        throw FilterError.typeError
                    }
                    
                    value = id
                default:
                    continue
                }
                
                filterDocument[key] = ["$\(filterOperator)": value]
            }
        }
        
        return Query(filterDocument)
    }
}

public enum FilterError : Error {
    case unquotedString
    case typeError
    case invalidOperator(String)
    case unfilterableField(String)
}
