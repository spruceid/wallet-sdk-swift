import Foundation

import WalletSdkRs
public func helloRust() -> String {
    return helloFfi()
}

public class Credential: Identifiable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}
