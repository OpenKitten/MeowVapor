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
    
    let lazy: Bool
    let connectionSettings: ConnectionSettings
    
    /// Connects to the MongoDB server or cluster located at the URI
    @available(*, deprecated, message: "A new initializer is introduced which is more explicit and connects lazily to your database. See our raedme for more information.")
    public convenience init(_ uri: String) throws {
        try self.init(uri: uri, lazy: false)
    }
    
    /// Connects to the MongoDB server or cluster located at the URI
    ///
    /// If `lazy` is set to true, the first error Meow throws will occur on the first query, not when creating the database, manager or context.
    /// The advantage of using `lazy` is the ability to call `request.make(Meow.Context.self)` and `request.make(Meow.Manager.self)`
    ///
    /// For backwards compatibility and predictability, lazy defaults to `false`
    public init(uri: String, lazy: Bool = true) throws {
        self.connectionSettings = try ConnectionSettings(uri)
        self.lazy = lazy
    }
    
    public func register(_ services: inout Services) throws {
        if lazy {
            services.register { container -> Meow.Manager in
                let database = try MongoKitten.Database.lazyConnect(settings: self.connectionSettings, on: container.eventLoop)
                return Meow.Manager(database: database)
            }
            
            services.register { container -> Future<Meow.Manager> in
                do {
                    let manager = try container.make(Meow.Manager.self)
                    return container.eventLoop.future(manager)
                } catch {
                    return container.eventLoop.future(error: error)
                }
            }
            
            services.register { container -> Meow.Context in
                return try container.make(Meow.Manager.self).makeContext()
            }
        } else {
            services.register { container in
                return MongoKitten.Database.connect(settings: self.connectionSettings, on: container.eventLoop).map { database in
                    Meow.Manager(database: database)
                }
            }
        }
        
        services.register { container -> Future<Context> in
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
    }
}

public extension Request {
    /// 🐈 Provides a Meow Context for use during this request
    @available(*, deprecated, message: "The recommended way of using Meow with Vapor Requests is now to use a lazily connecting database with Request.context(), which does not return a future.")
    public func meow() -> Future<Meow.Context> {
        return Future.flatMap(on: self) { try self.privateContainer.make(Future<Meow.Context>.self) }
    }
    
    /// 🐈 Provides a Meow Context for use during this request
    /// The context is made on the `privateContainer` of the request. This means that each request gets its own Context.
    public func context() throws -> Meow.Context {
        return try self.privateContainer.make()
    }
}
