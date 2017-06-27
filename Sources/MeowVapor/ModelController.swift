import Foundation
import Meow
import Vapor

fileprivate func keyPathSet<B, T>(on instance: B, path: WritableKeyPath<B, T>, value: Any?) throws {
    var instance = instance
    switch value {
    case let value as T:
        instance[keyPath: path] = value
    case let value as Int where T.self is Double.Type:
        instance[keyPath: path] = Double(value) as! T
    default:
        throw Meow.Error.invalidValue(key: String(describing: path), reason: "Value \(value ?? "nil") is not of type \(T.self)")
    }
}

fileprivate func keyPathSet<B, T>(on instance: B, path: WritableKeyPath<B, T?>, value: Any?) throws {
    var instance = instance
    switch value {
    case let value as T:
        instance[keyPath: path] = value
    case let value as Int where T.self is Double.Type:
        instance[keyPath: path] = Double(value) as? T
    case is NSNull:
        instance[keyPath: path] = nil
    default:
        throw Meow.Error.invalidValue(key: String(describing: path), reason: "Value \(value ?? "nil") is not of optoinal type \(T.self)")
    }
}

public typealias MeowVaporModel = Model & Parameterizable & KeyPathListable

open class ModelController<M : MeowVaporModel>: ResourceRepresentable {
    
    /// If set to true (the default), updates on variables will be handled incrementally
    open var flattenBeforeUpdate = true
    
    public typealias Key = String
    
    public init() {}
    
    /// The fields that are available for filtering. A MongoDB query may be generated based on the request for these properties.
    open var filterFields: [Key: Any.Type] = [:]
    
    /// The fields that are available for filtering. A MongoDB sort operation may be generated based on the request for these properties.
    open var sortFields: Set<Key> = []
    
    /// Set this closure to allow for implicit/default values.
    ///
    /// It is used with `store` requests. You can use this closure to infer certain values from the request.
    open var makeImplicitValues: ((Request) throws -> Document)?
    
    /// The properties you include here will never be included by the default implementation of `makeApiView`.
    /// If you specify the same property in both `privateFields` and `alwaysInclude`, the property will never be included (`privateFields` is more important).
    open var privateFields: Set<Key> = []
    
    /// The properties you include here will never be updated through the API.
    /// If you provide custom setters, these setters will still be accessible even if the key is included here.
    open var readonlyFields: Set<Key> = []
    
    /// You can provide custom setters, that will execute code instead of directly updating the instance through Meow.
    /// You can use custom keys here, that do not exist as properties in your model, or use the names of properties, in
    /// which case the property will always be updated using the setter.
    ///
    /// Custom setters are executed after the Meow update has finished. This means that if an error is thrown while running
    /// a custom setter, the other updates will already be finished.
    ///
    /// - warning: These setters currently only work for updates - not for store requests.
    open var customSetters: [String: (M, BSON.Primitive?) throws -> Void] = [:]
    
    /// The properties you include here will always be included in a request, even if the query parameter `include` does not specify them.
    /// If you specify the same property in both `privateFields` and `alwaysInclude`, the property will never be included (`privateFields` is more important).
    open var alwaysInclude: Set<String> = []
    
    open var keyPaths: [String : AnyKeyPath] = [:]
    
    // MARK: - Updates
    
    public enum UpdateError : Error {
        case invalidKey(String)
    }
    
    func update(instance: M, with document: Document) throws {
        var instance = instance
            
        try instance.update(with: document)
    }
    
    public typealias PaginatedFindResult = (total: Int, perPage: Int, currentPage: Int, lastPage: Int, from: Int, to: Int, data: AnySequence<M>)
    open func formatPagination(_ result: PaginatedFindResult, for request: Request) throws -> ResponseRepresentable {
        return try [
            "total": result.total,
            "per_page": result.perPage,
            "current_page": result.currentPage,
            "last_page": result.lastPage,
            "from": result.from,
            "to": result.to,
            "data": result.data.map{ try makeApiView(from: $0, for: request) }.makeDocument()
            ] as Document
    }
    
    open func makeResource() -> Resource<M> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            destroy: destroy
        )
    }
    
    /// This is meant as an extension point. The query is used by `index`.
    open func makeBaseQuery(for request: Request) throws -> MongoKitten.Query {
        return Query(Document())
    }
    
    open func show(request: Request, instance: M) throws -> ResponseRepresentable {
        return try makeApiView(from: instance, for: request)
    }
    
    open func destroy(request: Request, instance: M) throws -> ResponseRepresentable {
        try instance.delete()
        
        return Response(status: .noContent)
    }
    
    open func update(request: Request, instance: M) throws -> ResponseRepresentable {
        guard var document = flattenBeforeUpdate ? request.document?.flattened(skippingArrays: true) : request.document else {
            throw Abort.badRequest
        }
        
        document = try makeModelDocument(from: document, for: request)
        
        var setters: [() throws -> ()] = []
        for (key, setter) in customSetters {
            guard let newValue = document[key] else {
                continue
            }
            
            setters.append {
                try setter(instance, newValue)
            }
            
            document[key] = nil
        }
        
        try self.update(instance: instance, with: document)
        for setter in setters {
            try setter()
        }
        
        try instance.save()
        
        return Response(status: .noContent)
    }
    
    open func index(request: Request) throws -> ResponseRepresentable {
        let (result, usedPagination) = try M.paginatedFind(for: request,
                                                           baseQuery: makeBaseQuery(for: request),
                                                           allowFiltering: filterFields,
                                                           allowSorting: sortFields)
        
        if usedPagination {
            return try formatPagination(result, for: request)
        } else {
            return try result.data.map{ try makeApiView(from: $0, for: request) }.makeDocument()
        }
    }
    
    open func store(request: Request) throws -> ResponseRepresentable {
        guard var document = request.document else {
            throw Abort.badRequest
        }
        
        document = try makeModelDocument(from: document, for: request)
        
        if let append = try makeImplicitValues?(request) {
            document += append
        }
        
        let decoder = M.decoder
        let model = try decoder.decode(M.self, from: document)
        
        try model.save()
        
        return ["_id": model._id] as Document
    }
    
    /// Calls `serialize`, then `alter`
    open func makeApiView(from instance: M, for request: Request) throws -> Document {
        return try alterApiView(serialize(from: instance, for: request), for: request)
    }
    
    open func serialize(from instance: M, for request: Request) throws -> Document {
        var document = try M.encoder.encode(instance)
        
        for field in privateFields {
            document[field] = nil
        }
        
        return document
    }
    
    open func alterApiView(_ view: Document, for request: Request) throws -> Document {
        var document = view
        
        if var included = parseIncludeParameter(request.query?["include"]?.string ?? "") {
            included.formUnion(alwaysInclude.map { $0 })
            
            for key in document.keys {
                if !included.contains(key) {
                    document[key] = nil
                }
            }
        }
        
        return document
    }
    
    open func makeModelDocument(from input: Document, for request: Request) throws -> Document {
        var document = input
        
        for field in privateFields.union(readonlyFields) {
            document[field] = nil
        }
        
        return document
    }
    
    open func parseIncludeParameter(_ include: String) -> Set<String>? {
        guard include.characters.count > 0 else {
            return nil
        }
        
        let parts = include.components(separatedBy: ",")
        
        guard parts.count > 0 else {
            return nil
        }
        
        return Set(parts + ["_id"])
    }
    
}

open class ClosureBasedAccessControlModelController<M : MeowVaporModel> : ModelController<M> {
    
    public typealias MultipleAccessChecker = (Request) throws -> Void
    public typealias SingleAccessChecker = (Request, M) throws -> Void
    
    /// A closure that runs before every operation.
    /// Throw from the closure to prevent the request from executing.
    open var genericChecker: MultipleAccessChecker?
    
    /// A closure that runs before every operation on a single instance.
    /// Throw from the closure to prevent the request from executing.
    open var instanceAccessChecker: SingleAccessChecker?
    
    /// A closure that runs before every index operation.
    /// Throw from the closure to prevent the request from executing.
    open var indexAccessChecker: MultipleAccessChecker?
    
    /// A closure that runs before every store operation.
    /// Throw from the closure to prevent the request from executing.
    open var storeAccessChecker: MultipleAccessChecker?
    
    /// A closure that runs before every show operation.
    /// Throw from the closure to prevent the request from executing.
    open var showAccessChecker: SingleAccessChecker?
    
    /// A closure that runs before every update operation.
    /// Throw from the closure to prevent the request from executing.
    open var updateAccessChecker: SingleAccessChecker?
    
    /// A closure that runs before every destroy operation.
    /// Throw from the closure to prevent the request from executing.
    open var destroyAccessChecker: SingleAccessChecker?
    
    open override func show(request: Request, instance: M) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try instanceAccessChecker?(request, instance)
        try showAccessChecker?(request, instance)
        
        return try super.show(request: request, instance: instance)
    }
    
    open override func store(request: Request) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try storeAccessChecker?(request)
        
        return try super.store(request: request)
    }
    
    open override func index(request: Request) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try indexAccessChecker?(request)
        
        return try super.index(request: request)
    }
    
    open override func update(request: Request, instance: M) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try instanceAccessChecker?(request, instance)
        try updateAccessChecker?(request, instance)
        
        return try super.update(request: request, instance: instance)
    }
    
    open override func destroy(request: Request, instance: M) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try instanceAccessChecker?(request, instance)
        try destroyAccessChecker?(request, instance)
        
        return try super.destroy(request: request, instance: instance)
    }
    
}
