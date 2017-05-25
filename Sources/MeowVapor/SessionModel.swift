import MongoKitten

public protocol SessionModel {
    static var collection: MongoKitten.Collection { get }
    var _id: String { get }
    
    func serialize() -> Document
    
    var shouldDestroy: Bool { get }
    
    init?(document: Document) throws
    init(identifier: String)
}

extension SessionModel {
    public static func get(byIdentifier identifier: String) throws -> Self? {
        guard let document = try collection.findOne("_id" == identifier) else {
            return nil
        }
        
        return try Self.init(document: document)
    }
}
