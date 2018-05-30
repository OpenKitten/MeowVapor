@_exported import Vapor
@_exported import Meow
@_exported import MongoKitten

extension Meow.Manager: Service {}

public final class MeowProvider: Provider {
    let connectionSettings: ConnectionSettings
    
    public init(_ uri: String) throws {
        self.connectionSettings = try ConnectionSettings(uri)
    }
    
    public func register(_ services: inout Services) throws {
        let factory = BasicServiceFactory(Meow.Manager.self, supports: []) { container in
            return Meow.Manager(settings: self.connectionSettings, eventLoop: container.eventLoop)
        }
        
        services.register(factory)
    }
    
    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}
