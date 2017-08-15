import Foundation
import Meow
import Vapor
import HTTP
import MongoKitten
import BSON

/// Because `let type = type as? Array<Identifyable>.Type` won't work
fileprivate protocol DirtyHack {
    static var elementType: Any.Type { get }
}

extension Array : DirtyHack {
    static var elementType: Any.Type {
        return Element.self
    }
}

extension Optional : DirtyHack {
    static var elementType: Any.Type {
        return Wrapped.self
    }
}

extension Model {
    /// Performs a paginated or unpaginated find on the model, and returns the result.
    /// The API is intended to be public-facing.
    ///
    /// ## Pagination
    ///
    /// `paginatedFind` supports pagination through URL parameters. The following parameters are supported but all are optional:
    ///
    /// - `per_page`: The amount of results to fetch per page
    /// - `page`: The page number of the contents to fetch. If no page number is specified, this will be indicated in the return value (`usedPagination`)
    /// - `sort`: The sort order, in the following format: `date|desc,name_last|asc`
    /// - `filter`: Optional basic filter, something like "henk eq true" but I'm too lazy to document it right now so come back later maybe.
    ///
    /// - parameter request: The HTTP request for which the query will be executed. Used for the URL parameters. See above for supported parameters.
    /// - parameter baseQuery: The MK query, defaults to an empty query. This is the base query - filters may be added based on the other parameters.
    /// - parameter filterFields: The filters that are available in the `filter` URL parameter. Autocompletion should provide variable names.
    /// - parameter sortFields: The fields that are sortable. Autocompletion should provide variable names.
    /// - parameter maximumPerPage: The maximum amount of results the find will return at once
    ///
    /// - returns: The query result, and if the operation used pagination
    public static func paginatedFind(
        for request: Request,
        baseQuery: MongoKitten.Query = Query(Document()),
        allowFiltering filterFields: [String: Any.Type] = [:],
        allowSorting sortFields: Set<String> = [],
        maximumPerPage: Int? = 1000
        ) throws -> (result: PaginatedFindResult, usedPagination: Bool) {
        
        let specifiedPage: Int? = try request.query?.get("page")
        var perPage: Int? = try request.query?.get("per_page") ?? maximumPerPage
        let page: Int = specifiedPage ?? 1
        let sortSpecification = (try request.query?.get("sort") as String?) ?? ""
        let filterSpecification = (try request.query?.get("filter") as String?) ?? ""
        
        if let givenPerPage = perPage, let maximumPerPage = maximumPerPage, givenPerPage > maximumPerPage {
            perPage = maximumPerPage
        }
        
        let finalQuery = try parseFilterString(filterSpecification, fields: filterFields) && baseQuery
        let finalSort = try parseSortString(sortSpecification, fields: sortFields)
        
        let result = try Self.paginatedFind(finalQuery,
                                            sortedBy: finalSort,
                                            page: page,
                                            perPage: perPage)
        
        return (result: result, usedPagination: specifiedPage != nil)
    }
    
    public static func parseSortString(_ spec: String, fields: Set<String>) throws -> Sort? {
        var sortSpecification = Sort()
        
        for sort in spec.components(separatedBy: ",") where !sort.isEmpty {
            let pieces = sort.components(separatedBy: "|")
            
            guard pieces.count == 2, !pieces[0].isEmpty else {
                continue
            }
            
            guard let key = fields.first(where: { $0 == pieces[0] }) else {
                throw FindError.unsortableField(pieces[0])
            }
            
            let method = pieces[1].lowercased()
            
            if method == "asc" {
                sortSpecification[key] = .ascending
            } else if method == "desc" {
                sortSpecification[key] = .descending
            } else {
                // TODO: Throw?
                continue
            }
        }
        
        return sortSpecification.makeDocument().count > 0 ? sortSpecification : nil
    }
    
    public static func parseFilterString(_ spec: String, fields: [String: Any.Type]) throws -> Query {
        var filterQuery = Query.init()
        
        // Filter conditions are separated by commas, so we'll split them and loop through them
        for condition in spec.components(separatedBy: ",") where !condition.isEmpty {
            let pieces = condition.components(separatedBy: " ")
            
            guard pieces.count >= 3, !pieces[0].isEmpty, !pieces[1].isEmpty, !pieces[2].isEmpty else {
                continue
            }
            
            let key = pieces[0]
            let op = pieces[1]
            let queryValue = pieces[2..<pieces.endIndex].joined()
            
            guard var type = fields[key] else {
                throw FindError.unfilterableField(key)
            }
            
            // yes, two times
            if let collectionType = type as? DirtyHack.Type {
                type = collectionType.elementType
            }
            
            if let collectionType = type as? DirtyHack.Type {
                type = collectionType.elementType
            }
            
            switch op {
            case "cont":
                var unquotedInput = queryValue
                guard unquotedInput.characters.removeFirst() == "'" && unquotedInput.characters.removeLast() == "'" else {
                    throw FindError.unquotedString
                }
                filterQuery = filterQuery && Query([key: BSON.RegularExpression(pattern: Foundation.NSRegularExpression.escapedPattern(for: unquotedInput), options: .caseInsensitive)])
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
                    throw FindError.invalidOperator(op)
                }
                
                let value: BSON.Primitive
                var inputValue = queryValue
                
                switch type {
                case is Double.Type:
                    guard let double = Double(inputValue) else {
                        throw FindError.typeError
                    }
                    
                    value = double
                case is Int32.Type, is Int64.Type:
                    guard let int = Int(inputValue) else {
                        throw FindError.typeError
                    }
                    
                    value = int
                case is Date.Type:
                    guard let timestamp = Double(inputValue) else {
                        throw FindError.typeError
                    }
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    value = date
                case is String.Type:
                    guard inputValue.characters.count >= 2 else {
                        throw FindError.typeError
                    }
                    
                    guard inputValue.characters.removeFirst() == "'" && inputValue.characters.removeLast() == "'" else {
                        throw FindError.unquotedString
                    }
                    
                    value = inputValue
                case is Bool.Type:
                    switch inputValue {
                    case "true": value = true
                    case "false": value = false
                    default: throw FindError.typeError
                    }
                case is ObjectId.Type, is Referencing.Type:
                    guard let id = try? ObjectId(inputValue) else {
                        throw FindError.typeError
                    }
                    
                    value = id
                default:
                    throw FindError.filterTypeError(field: key, type: type, model: Self.self)
                }
                
                filterQuery = filterQuery && Query([key: ["$\(filterOperator)": value] as Document])
            }
        }
        
        return filterQuery
    }
}

public enum FindError: Error {
    case unquotedString
    case typeError
    case invalidOperator(String)
    case unfilterableField(String)
    case unsortableField(String)
    case filterTypeError(field: String, type: Any.Type, model: Any.Type)
}

extension FindError: Vapor.Debuggable {
    public var reason: String {
        switch self {
        case .unquotedString: return "The filter operation string was not properly quoted"
        case .typeError: return "The actual type and given filter type are not compatible"
        case .invalidOperator(let op): return "The operator \(op) is not valid in the given context"
        case .unfilterableField(let field): return "The field '\(field)' is not filterable"
        case .unsortableField(let field): return "The field '\(field)' is not sortable"
        case .filterTypeError(let field, let type, let model): return "A filter query cannot be generated for type of the field \(field) on \(model), because the type \(type) is unsupported"
        }
    }
    
    public var identifier: String {
        return "FindError"
    }
    
    public var possibleCauses: [String] {
        return ["The request parameters are not valid"]
    }
    
    public var suggestedFixes: [String] {
        return ["Adjust the request parameters"]
    }
}
