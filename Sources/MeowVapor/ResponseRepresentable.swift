import Vapor
import Cheetah
import BSON
import HTTP

extension Document : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.makeExtendedJSON().serialize()))
    }
}

extension JSONObject : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.serialize()))
    }
}

extension JSONArray : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.serialize()))
    }
}
