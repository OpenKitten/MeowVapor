@_exported import Vapor
@_exported import Meow
@_exported import MongoKitten

extension Meow.Manager: Service {}
extension Meow.Context: Service {}

extension Future: Service where T: Service {}

public final class MeowProvider: Provider {
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
    
    let connectionSettings: ConnectionSettings
    
    public init(_ uri: String) throws {
        self.connectionSettings = try ConnectionSettings(uri)
    }
    
    public func register(_ services: inout Services) throws {
        let managerFactory = BasicServiceFactory(Future<Meow.Manager>.self, supports: []) { container in
            return MongoKitten.Database.connect(settings: self.connectionSettings, on: container.eventLoop).map { database in
                Meow.Manager(database: database)
            }
        }
        
        let contextFactory = BasicServiceFactory(Future<Meow.Context>.self, supports: []) { container in
            let managerContainer: Container
            // The context manager should be on the super container (so every request has its own context but shares a database connection with other requests)
            if let subContainer = container as? SubContainer {
                managerContainer = subContainer.superContainer
            } else {
                managerContainer = container
            }
            
            let manager = try managerContainer.make(Future<Manager>.self)
            return manager.map { $0.makeContext() }
        }
        
        services.register(managerFactory)
        services.register(contextFactory)
    }
}

public extension Request {
    /// 🐈 Provides a Meow Context for use during this request
    public func meow() -> Future<Meow.Context> {
        return Future.flatMap(on: self) { try self.privateContainer.make(Future<Meow.Context>.self) }
    }
    
    @available(*, deprecated, message: "Use request.meow() instead of request.make(Context.self) to create a Meow context. Meow contexts should have a lifetime of one request, and making it on the request would allow the context to exceed this lifespan.")
    public func make(_ type: Meow.Context.Type) throws -> Meow.Context {
        assertionFailure()
        return try self.make()
    }
}
