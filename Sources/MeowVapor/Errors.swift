import Cheetah
import Vapor

/// An error that can be represented as a Cheetah JSONObject
public protocol JSONError : Swift.Error, ResponseRepresentable {
    /// Creates a JSONObject from this error that can be returned to the API consumer
    func makeJSON() throws -> JSONObject
}

extension JSONError {
    /// Creates a response from the JSON Error that can be returned to the API consumer
    public func makeResponse() throws -> Response {
        return try self.makeJSON().makeResponse()
    }
}
