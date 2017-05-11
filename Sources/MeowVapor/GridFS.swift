import Meow
import Foundation
import MongoKitten
import HTTP
import Vapor

extension File : ResponseRepresentable {
    /// Returns a GridFS file as a response
    public func makeResponse() throws -> Response {
        guard let file = try GridFS.default.findOne(byID: id) else {
            throw Abort.notFound
        }
        
        var headers: [HeaderKey: String] = [:]
        
        if let type = file.contentType {
            headers["Content-Type"] = type
        }
        
        return Response(status: .ok, headers: headers) { stream in
            for chunk in file {
                try stream.write(chunk.data)
            }
            
            try stream.close()
        }
    }
}

extension Optional where Wrapped : ResponseRepresentable {
    /// Returns an optional if it contains something
    public func makeResponse() throws -> Response {
        guard let wrapped = self else {
            throw Abort.notFound
        }
        
        return try wrapped.makeResponse()
    }
}
