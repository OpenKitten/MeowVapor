//import JSON
//import Cookies
//import XCTest
//@testable import MeowVapor
//import HTTP
//import struct Cheetah.JSONArray
//import struct Cheetah.JSONObject
//import protocol Cheetah.Value
//
//class MeowVaporTests: XCTestCase {
////    func testJSON() throws {
////        let json: JSONObject = [
////            "username": "Joannis",
////            "password": "hunter2",
////            "pi": 3.14,
////            "favourites": ["Swift", "MongoDB"] as JSONArray
////        ]
////
////        let vaporJSON = JSON(.object([
////            "username": "Joannis",
////            "password": "hunter2",
////            "pi": 3.14,
////            "favourites": JSON(.array(["Swift", "MongoDB"]))
////        ]))
////
////        XCTAssertEqual(try json.makeJSON(), vaporJSON)
////    }
//
//    override func setUp() {
//        try! Meow.init("mongodb://localhost/meowvapor")
//        try! Meow.database.drop()
//    }
//
//    func testJSONModel() throws {
//
//    }
//
//    func testCheetahVaporJSONConversion() throws {
//        let json: JSON = [
//            "key": 3,
//            "pi": 3.14,
//            "username": "Henk",
//            "admin": true,
//            "nums": [1, 2, 3, 4, 5, 6, 7, 9]
//        ]
//
//        let cheetahJSON = try JSONObject(json: json)
//
//        XCTAssertEqual(cheetahJSON, [
//            "key": 3,
//            "pi": 3.14,
//            "username": "Henk",
//            "admin": true,
//            "nums": [1, 2, 3, 4, 5, 6, 7, 9] as JSONArray
//        ])
//
//        XCTAssertEqual(try cheetahJSON.makeJSON(), json)
//    }
//
//    func testSessions() throws {
//        let middleware = SessionsMiddleware<UserSession>()
//
//        func runRequest(method: HTTP.Method = .get, uri: String = "login", cookies: Cookies = Cookies(), _ closure: @escaping BasicResponder.Closure) throws -> Response {
//            let request = Request(method: method, uri: uri)
//            request.cookies = cookies
//
//            return try middleware.respond(to: request, chainingTo: BasicResponder(closure))
//        }
//
//        let user = User(username: "Joannis")
//        try user.save()
//
//        var response = try runRequest { request in
//            guard let userSession = UserSession.current(for: request) else {
//                XCTFail()
//                return "fail".makeResponse()
//            }
//
//            XCTAssertNil(userSession.user)
//
//            userSession.user = user
//
//            XCTAssertNotNil(userSession.user)
//
//            return "success".makeResponse()
//        }
//
//        guard let token = response.cookies[middleware.cookieName] else {
//            XCTFail()
//            return
//        }
//
//        XCTAssertEqual(response.body.bytes ?? [], "success".makeResponse().body.bytes ?? [])
//
//        response = try runRequest(cookies: response.cookies) { request in
//            guard let userSession = UserSession.current(for: request) else {
//                XCTFail()
//                return "fail".makeResponse()
//            }
//
//            XCTAssertNotNil(userSession.user)
//            XCTAssertEqual(userSession.user?.username, "Joannis")
//
//            return "success".makeResponse()
//        }
//
//        let sessionUser = try UserSession.findOne("sessionToken" == token)?.user
//
//        XCTAssertNotNil(sessionUser)
//        XCTAssert(user == sessionUser)
//
//        XCTAssertEqual(response.body.bytes ?? [], "success".makeResponse().body.bytes ?? [])
//    }
//
////    static var allTests = [
////        ("testExample", testJSON),
////    ]
//}

