import Routing
import HTTP
import Cheetah

typealias CheetahValue = Cheetah.Value

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

/// A JSON erro that describes the issues in the request 
public protocol JSONErrorModel : JSONError, RequestInitializable {}

/// A literal JSONObject error
public struct BasicJSONError : JSONError {
    /// The error's storage. Can be mutated
    public var error: JSONObject
    
    /// Creates a BasicJSONError from an existing JSONObject
    public init(_ error: JSONObject) {
        self.error = error
    }
    
    /// Creates a JSONObject from this BasicJSONError by returning the stored JSONObject
    public func makeJSON() throws -> JSONObject {
        return error
    }
}

/// A JSON Model that can be created from a request on a route
public protocol JSONRequestModel : RequestInitializable {
    /// Creates a new JSONRequestModel from a JSONObject.
    ///
    /// If the JSONRequest may not be initialized with a JSONObject you can fail the initializer by returning `nil` or throw an error
    init?(jsonObject: JSONObject) throws
    
    /// Creates a new JSONRequestModel from a JSONArray.
    ///
    /// If the JSONRequest may not be initialized with a JSONArray you can fail the initializer by returning `nil` or throw an error
    init?(jsonArray: JSONArray) throws
}

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

/// A JSON Model that can be responded with to a request
public protocol JSONResponseModel : ResponseRepresentable {
    /// Serializes the JSONRequest.
    ///
    /// Useful for API clients
    func makeJSON() throws -> Value
}

extension JSONResponseModel {
    /// Returns a Cheetah JSON value as a Response
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(try self.makeJSON().serialize()))
    }
}

/// A JSON Route that has a predefined JSONRequest and JSON Response
public protocol JSONRoute {
    associatedtype Request : JSONRequestModel
    associatedtype Response : JSONResponseModel
    associatedtype Error : JSONErrorModel
    
    var method: HTTP.Method { get }
    var path: [String] { get }
    var responder: Responder { get }
}

public struct BasicJSONRoute<Req: JSONRequestModel, Resp: JSONResponseModel, Err: JSONErrorModel> : JSONRoute {
    public typealias Request = Req
    public typealias Response = Resp
    public typealias Error = Err
    
    public typealias Closure = ((Request) throws -> Response)
    
    public var method: HTTP.Method
    public var path: [String]
    public var closure: Closure
    
    public var responder: Responder {
        return BasicResponder { httpRequest in
            do {
                guard let request = try Request(from: httpRequest) else {
                    guard let error = try Error(from: httpRequest) else {
                        throw BasicJSONError([
                            "erorr": "Unknown"
                        ])
                    }
                    
                    return try error.makeResponse()
                }
                
                return try self.closure(request).makeResponse()
            } catch let error as JSONError {
                return try error.makeResponse()
            }
        }
    }
    
    public init(method: HTTP.Method = .wildcard, _ path: String..., _ closure: @escaping Closure) {
        self.method = method
        self.path = path
        self.closure = closure
    }
}

extension RouteBuilder {
    public func register<Route: JSONRoute>(_ route: Route) {
        self.register(method: route.method, path: route.path, responder: route.responder)
    }
}
