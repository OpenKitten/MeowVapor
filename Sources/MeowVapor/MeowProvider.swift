@_exported import Vapor
@_exported import Meow
@_exported import MongoKitten

extension Meow.Manager: Service {}
extension Meow.Context: Service {}

public final class MeowProvider: Provider {
    let connectionSettings: ConnectionSettings
    
    public init(_ uri: String) throws {
        self.connectionSettings = try ConnectionSettings(uri)
    }
    
    public func register(_ services: inout Services) throws {
        let managerFactory = BasicServiceFactory(Meow.Manager.self, supports: []) { container in
            return Meow.Manager(settings: self.connectionSettings, eventLoop: container.eventLoop)
        }
        
        let contextFactory = BasicServiceFactory(Meow.Context.self, supports: []) { container in
            let managerContainer: Container
            // The context manager should be on the super container (so every request has its own context but shares a database connection with other requests)
            if let subContainer = container as? SubContainer {
                managerContainer = subContainer.superContainer
            } else {
                managerContainer = container
            }
            
            let manager = try managerContainer.make(Manager.self)
            return manager.makeContext()
        }
        
        services.register(managerFactory)
        services.register(contextFactory)
    }
    
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}

public extension Request {
    /// 🐈 Provides a Meow Context for use during this request
    public func meow() throws -> Meow.Context {
        return try self.privateContainer.make(Meow.Context.self)
    }
    
    @available(*, deprecated, message: "Use request.meow() instead of request.make(Context.self) to create a Meow context. Meow contexts should have a lifetime of one request, and making it on the request would allow the context to exceed this lifespan.")
    public func make(_ type: Meow.Context.Type) throws -> Meow.Context {
        assertionFailure()
        return try self.make()
    }
}
