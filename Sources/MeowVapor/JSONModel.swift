import HTTP
import Cheetah

/// A type that is initializable be either a JSONObject, JSONArray or both
public protocol JSONModel {
    /// Creates a new JSONRequestModel from a JSONObject.
    ///
    /// If the JSONRequest may not be initialized with a JSONObject you can fail the initializer by returning `nil` or throw an error
    init?(jsonObject: JSONObject) throws
    
    /// Creates a new JSONRequestModel from a JSONArray.
    ///
    /// If the JSONRequest may not be initialized with a JSONArray you can fail the initializer by returning `nil` or throw an error
    init?(jsonArray: JSONArray) throws
    
    /// Serializes the JSONRequest.
    ///
    /// Useful for API clients
    func makeJSON() throws -> Value
}

public protocol JSONRequestModel : JSONModel, RequestInitializable {}

extension JSONRequestModel {
    public init?(from request: Request) throws {
        guard let value = request.jsonValue else {
            return nil
        }
        
        switch value {
        case let object as JSONObject:
            try self.init(jsonObject: object)
        case let array as JSONArray:
            try self.init(jsonArray: array)
        default:
            return nil
        }
    }
}

public protocol JSONResponseModel : JSONModel, ResponseRepresentable {}

extension JSONResponseModel {
    /// Returns a Cheetah JSON value as a Response
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(try self.makeJSON().serialize()))
    }
}
