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
    
    public typealias AuthorizationChecker = (Request) throws -> Void
    
    public init() {}
    
    open var filterFields: Set<M.Key> = []
    open var sortFields: Set<M.Key> = []
    open var authorizationChecker: AuthorizationChecker?
    
    open func makeResource() -> Resource<M> {
        return Resource(
            index: index,
            store: store,
            show: show,
            modify: modify,
            destroy: destroy
        )
    }
    
    open func show(request: Request, instance: M) throws -> ResponseRepresentable {
        try authorizationChecker?(request)
        
        return instance.serialize()
    }
    
    open func destroy(request: Request, instance: M) throws -> ResponseRepresentable {
        try authorizationChecker?(request)
        
        try instance.delete()
        
        return Response(status: .noContent)
    }
    
    open func modify(request: Request, instance: M) throws -> ResponseRepresentable {
        try authorizationChecker?(request)
        
        guard let document = request.document else {
            throw Abort.badRequest
        }
        
        try instance.update(with: document)
        
        return Response(status: .noContent)
    }
    
    open func index(request: Request) throws -> ResponseRepresentable {
        try authorizationChecker?(request)
        
        let (result, usedPagination) = try M.paginatedFind(for: request,
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
        try authorizationChecker?(request)
        
        guard let document = request.document else {
            throw Abort.badRequest
        }
        
        _ = try M(newFrom: document)
        
        return Response(status: .noContent)
    }
    
}
