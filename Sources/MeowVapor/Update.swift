import Meow
import Vapor
import Foundation

extension ContentContainer {
    public func update<D: QueryableModel>(_ instance: D, maxSize: Int = 65_536, using decoder: JSONDecoder = JSONDecoder(), withAllowedKeyPaths keyPaths: [MeowWritableKeyPath]) throws -> Future<[PartialKeyPath<D>]> {
        return try decode(DecoderExtractor.self, maxSize: maxSize, using: decoder).map { extracted in
            let decoder = extracted.decoder
            return try decoder.update(instance, withAllowedKeyPaths: keyPaths)
        }
    }
}
