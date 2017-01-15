import XCTest
@testable import MeowVapor


class FlowTests: XCTestCase {
    override func setUp() {
        try! Meow.init("mongodb://localhost:27017/vapor-meow")
    }
    
    func testExample() throws {
        let user0 = User(username: "piet", password: "123")
        let user1 = User(username: "henk", password: "321")
        let user2 = User(username: "klaas", password: "12345")
        let user3 = User(username: "harrie", password: "bob")
        let user4 = User(username: "bob", password: "harrie")
        
        try user0.save()
        try user1.save()
        try user2.save()
        try user3.save()
        try user4.save()
        
        XCTAssertEqual(try User.count { user in
            return user.username == "piet" || user.password == "321"
        }, 2)
        
        XCTAssertEqual(try User.count { user in
            return user.username == "piet" || user.password == "123"
            }, 1)
        
        XCTAssertEqual(try User.count { user in
            return user.username == "harrie" || user.password == "harrie"
            }, 2)
        
        XCTAssertEqual(try User.count(), 5)
    }


    static var allTests : [(String, (FlowTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}


final class User: Model {
    var id = ObjectId()
    
    var username: String
    var password: String
    var age: Int?
    var gender: Gender?
    var details: Details?
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

enum Gender: String, Embeddable {
    case male, female
}

final class Details: Embeddable {
    var firstName: String?
    var lastName: String?
}
