@testable import SpruceIDMobileSdk
import XCTest

final class StorageManager: XCTestCase {
    func storage_test() throws {
        let key = "test_key"
        let value = Data("Some random string of text. 😎".utf8)

        XTCAssertNoThrow(add(key: key, value: value), "\(classForCoder):\(#function): Failed add() value for key.")

        try XTCAssertNoThrow(let payload = get(key: key), "\(classForCoder):\(#function): Failed get() value for key.")

        XTCAssert(payload == value, "\(classForCoder):\(#function): Mismatch between stored & retrieved value.")

        try XTCAssertNoThrow(remove(key: key), "\(classForCoder):\(#function): Failed remove() value for key.")
    }
}
