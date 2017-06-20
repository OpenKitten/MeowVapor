import Meow
import Foundation
import MongoKitten
import HTTP
import Vapor

extension FileReference : ResponseRepresentable {
    /// Returns a GridFS file as a response
    public func makeResponse() throws -> Response {
        var headers: [HeaderKey: String] = [:]
        
        let file = try self.resolve()
        
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
    
    public init(storingFileFrom request: Request, named formName: String = "file", allowing contentTypes: [String]? = nil) throws {
        let file = try request.getFile(allowing: contentTypes, formName: formName)
        
        reference = try Meow.fs.store(data: file.data,
                               named: file.name,
                               withType: file.contentType)
    }
}

extension Request {
    func getFile(allowing contentTypes: [String]? = nil, formName name: String = "file") throws -> (contentType: String, name: String?, data: [UInt8]) {
        if let form = self.formData {
            guard let part = form[name]?.part else {
                throw Abort(.badRequest,
                                 reason: "File not found in multipart")
            }
            
            guard let type = part.headers["Content-Type"] else {
                throw Abort(.badRequest,
                            reason: "File type not present in multipart")
            }
            
            if let contentTypes = contentTypes {
                guard contentTypes.contains(type) else {
                    throw Abort(.badRequest,
                                reason: "Content type \(type) not allowed")
                }
            }
            
            // TODO: break here? check how to get filename
            return (contentType: type, name: "", data: part.body)
        }
        
        if let type = self.contentType, (contentTypes?.contains(type) ?? true) {
            guard let bytes = self.body.bytes else {
                throw Abort(.badRequest,
                            reason: "Request does not contain body")
            }
            
            return (contentType: type, name: nil, data: bytes)
        }
        
        throw Abort(.badRequest,
                    reason: "Could not get file from request")
    }

}

public extension Optional where Wrapped == FileReference {
    public func makeResponse() throws -> Response {
        guard let wrapped = self else {
            throw Abort.notFound
        }
        
        return try wrapped.makeResponse()
    }
}
