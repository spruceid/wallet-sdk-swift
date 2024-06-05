//
//  KeyManager.swift
//
//
//  Created by Kuba on 6/4/24.
//

import XCTest
@testable import SpruceIDWalletSdk

final class DataConversions: XCTestCase {
 
  /**
   * Tests to see if the base 64 url encoding correctly converts the sample data and
   * replaces special characters.
   */
  func testBase64EncodedUrlSafe() throws {
    let staticString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=+ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/="
    let sampleData: Data = staticString.data(using: .utf8)!
    let base64 = sampleData.base64EncodedUrlSafe
    
    // Generated independently
    let expectedBase64String = "QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVowMTIzNDU2Nzg5Ky89K0FCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlaMDEyMzQ1Njc4OSsvPQ"
    
    XCTAssertEqual(base64, expectedBase64String)
  }
}
