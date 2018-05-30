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
            let manager = try container.make(Manager.self)
            return manager.makeContext()
        }
        
        services.register(managerFactory)
        services.register(contextFactory)
    }
    
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}
