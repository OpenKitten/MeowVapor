import Vapor
import Cheetah
import BSON
import HTTP

extension Document : ResponseRepresentable {
    /// Returns a BSON Document as a Response
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.makeExtendedJSON().serialize()))
    }
}

extension JSONObject : ResponseRepresentable {
    /// Returns a Cheetah JSONObject as a Response
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.serialize()))
    }
}

extension JSONArray : ResponseRepresentable {
    /// Returns a Cheetah JSONArray as a Response
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.serialize()))
    }
}
