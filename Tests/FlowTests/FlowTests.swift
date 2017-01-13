import XCTest
@testable import Flow

class FlowTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Flow().text, "Hello, World!")
    }


    static var allTests : [(String, (FlowTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
