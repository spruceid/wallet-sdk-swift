import XCTest
@testable import SpruceIDWalletSdk

class HelloTests: XCTestCase {
    func testHelloRust() {
        XCTAssertEqual(helloRust(), "Hello from Rust!")
    }
}
