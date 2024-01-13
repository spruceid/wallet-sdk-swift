import XCTest
@testable import WalletSdk

class HelloTests: XCTestCase {
    func testHelloRust() {
        XCTAssertEqual(helloRust(), "Hello from Rust!")
    }
}
