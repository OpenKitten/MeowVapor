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

open class ModelController<M : Model & Parameterizable>: ResourceRepresentable {
    
    public init() {}
    
    open var filterFields: Set<M.Key> = []
    open var sortFields: Set<M.Key> = []
    open var makeImplicitValues: ((Request) throws -> M.Values)?
    open var privateFields: Set<M.Key> = []
    
    open func formatPagination(_ result: M.PaginatedFindResult, for request: Request) -> ResponseRepresentable {
        return [
            "total": result.total,
            "per_page": result.perPage,
            "current_page": result.currentPage,
            "last_page": result.lastPage,
            "from": result.from,
            "to": result.to,
            "data": result.data.map{ $0.serialize() }.makeDocument()
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
        return makeApiView(from: instance, for: request)
    }
    
    open func destroy(request: Request, instance: M) throws -> ResponseRepresentable {
        try instance.delete()
        
        return Response(status: .noContent)
    }
    
    open func update(request: Request, instance: M) throws -> ResponseRepresentable {
        guard var document = request.document else {
            throw Abort.badRequest
        }
        
        document = makeModelDocument(from: document, for: request)
        
        try instance.update(with: document)
        
        return Response(status: .noContent)
    }
    
    open func index(request: Request) throws -> ResponseRepresentable {
        let (result, usedPagination) = try M.paginatedFind(for: request,
                                                           baseQuery: makeBaseQuery(for: request),
                                                           allowFiltering: filterFields,
                                                           allowSorting: sortFields)
        
        if usedPagination {
            return formatPagination(result, for: request)
        } else {
            return result.data.map{ $0.serialize() }.makeDocument()
        }
    }
    
    open func store(request: Request) throws -> ResponseRepresentable {
        guard var document = request.document else {
            throw Abort.badRequest
        }
        
        document = makeModelDocument(from: document, for: request)
        
        if let append = try makeImplicitValues?(request) {
            document += append.serialize()
        }
        
        try M.validateUpdate(with: document)
        
        let model = try M(newFrom: document)
        
        return ["_id": model._id] as Document
    }
    
    open func makeApiView(from instance: M, for request: Request) -> Document {
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
    
    open func makeModelDocument(from input: Document, for request: Request) -> Document {
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
