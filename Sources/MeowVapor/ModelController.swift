import Meow
import Vapor

open class ModelController<M : Model & Parameterizable>: ResourceRepresentable {
    
    public init() {}
    
    /// The fields that are available for filtering. A MongoDB query may be generated based on the request for these properties.
    open var filterFields: Set<M.Key> = []
    
    /// The fields that are available for filtering. A MongoDB sort operation may be generated based on the request for these properties.
    open var sortFields: Set<M.Key> = []
    
    /// Set this closure to allow for implicit/default values.
    ///
    /// It is used with `store` requests. You can use this closure to infer certain values from the request.
    open var makeImplicitValues: ((Request) throws -> M.Values)?
    
    /// The properties you include here will never be included by the default implementation of `makeApiView`.
    /// If you specify the same property in both `privateFields` and `alwaysInclude`, the property will never be included (`privateFields` is more important).
    open var privateFields: Set<M.Key> = []
    
    /// The properties you include here will always be included in a request, even if the query parameter `include` does not specify them.
    /// If you specify the same property in both `privateFields` and `alwaysInclude`, the property will never be included (`privateFields` is more important).
    open var alwaysInclude: Set<M.Key> = []
    
    open func formatPagination(_ result: M.PaginatedFindResult, for request: Request) throws -> ResponseRepresentable {
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
        guard var document = request.document else {
            throw Abort.badRequest
        }
        
        document = try makeModelDocument(from: document, for: request)
        
        try instance.update(with: document)
        
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
            document += append.serialize()
        }
        
        try M.validateUpdate(with: document)
        
        let model = try M(newFrom: document)
        
        return ["_id": model._id] as Document
    }
    
    /// Calls `serialize`, then `alter`
    open func makeApiView(from instance: M, for request: Request) throws -> Document {
        return try alterApiView(serialize(from: instance, for: request), for: request)
    }
    
    open func serialize(from instance: M, for request: Request) throws -> Document {
        var document = instance.serialize() as Document
        
        for field in privateFields {
            document[field.keyString] = nil
        }
        
        for key in M.Key.all where key.type is BaseModel.Type {
            guard let id = ObjectId(document[key.keyString]["$id"]) else {
                continue
            }
            
            document[key.keyString] = id
        }
        
        return document
    }
    
    open func alterApiView(_ view: Document, for request: Request) throws -> Document {
        var document = view
        
        if var included = parseIncludeParameter(request.query?["include"]?.string ?? "") {
            included.formUnion(alwaysInclude.map { $0.keyString })
            
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
        
        for field in privateFields {
            document[field.keyString] = nil
        }
        
        for key in M.Key.all {
            guard let type = key.type as? BaseModel.Type, let id = ObjectId(document[key.keyString]) else {
                continue
            }
            
            document[key.keyString] = DBRef(referencing: id, inCollection: type.collection)
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

open class ClosureBasedAccessControlModelController<M : Model & Parameterizable> : ModelController<M> {
    
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
