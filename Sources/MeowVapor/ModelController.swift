import Meow
import Vapor

extension BaseModel where Self : StringInitializable {
    public init?(_ string: String) throws {
        guard let instance = try Self.findOne("_id" == ObjectId(string)) else {
            return nil
        }
        
        self = instance
    }
}

open class ModelController<M : Model & StringInitializable>: ResourceRepresentable {
    
    public init() {}
    
    open var filterFields: Set<M.Key> = []
    open var sortFields: Set<M.Key> = []
    open var makeImplicitValues: ((Request) throws -> M.Values)?
    
    open func makeResource() -> Resource<M> {
        return Resource(
            index: index,
            store: store,
            show: show,
            modify: modify,
            destroy: destroy
        )
    }
    
    /// This is meant as an extension point. The query is used by `index`.
    open func makeBaseQuery(for request: Request) throws -> MongoKitten.Query {
        return Query(Document())
    }
    
    open func show(request: Request, instance: M) throws -> ResponseRepresentable {
        return instance.serialize()
    }
    
    open func destroy(request: Request, instance: M) throws -> ResponseRepresentable {
        try instance.delete()
        
        return Response(status: .noContent)
    }
    
    open func modify(request: Request, instance: M) throws -> ResponseRepresentable {
        guard let document = request.document else {
            throw Abort.badRequest
        }
        
        try instance.update(with: document)
        
        return Response(status: .noContent)
    }
    
    open func index(request: Request) throws -> ResponseRepresentable {
        let (result, usedPagination) = try M.paginatedFind(for: request,
                                                           baseQuery: makeBaseQuery(for: request),
                                                           allowFiltering: filterFields,
                                                           allowSorting: sortFields)
        
        let data = result.data.map{ $0.serialize() }.makeDocument()
        
        if usedPagination {
            return [
                "total": result.total,
                "per_page": result.perPage,
                "current_page": result.currentPage,
                "lastPage": result.lastPage,
                "from": result.from,
                "to": result.to,
                "data": data
            ] as Document
        } else {
            return data
        }
    }
    
    open func store(request: Request) throws -> ResponseRepresentable {
        guard var document = request.document else {
            throw Abort.badRequest
        }
        
        if let append = try makeImplicitValues?(request) {
            document += append.serialize()
        }
        
        _ = try M(newFrom: document)
        
        return Response(status: .noContent)
    }
    
}

open class ClosureBasedAccessControlModelController<M : Model & StringInitializable> : ModelController<M> {
    
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
    
    /// A closure that runs before every modify operation.
    /// Throw from the closure to prevent the request from executing.
    open var modifyAccessChecker: SingleAccessChecker?
    
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
    
    open override func modify(request: Request, instance: M) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try instanceAccessChecker?(request, instance)
        try modifyAccessChecker?(request, instance)
        
        return try super.modify(request: request, instance: instance)
    }
    
    open override func destroy(request: Request, instance: M) throws -> ResponseRepresentable {
        try genericChecker?(request)
        try instanceAccessChecker?(request, instance)
        try destroyAccessChecker?(request, instance)
        
        return try super.destroy(request: request, instance: instance)
    }
    
}
