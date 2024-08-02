import Foundation

enum W3CError: Error {
    case InitializationError(String)
}

public class W3CVC: Credential {
    private let credentialString: String
    private let credential: GenericJSON?
    
    public init(credentialString: String) throws {
        self.credentialString = credentialString
        if let data = credentialString.data(using: .utf8) {
            do {
                let json = try JSONDecoder().decode(GenericJSON.self, from: data)
                self.credential = json
                super.init(id: json["id"]!.toString())
            } catch let error as NSError {
                throw error
            }
        } else {
            self.credential = nil
            super.init(id: "")
            throw W3CError.InitializationError("Failed to process credential string.")
        }
    }
    
    override public func get(keys: [String]) -> [String:GenericJSON] {
        if let c = credential!.dictValue {
            return c.filter { keys.contains($0.key) }
        } else {
            return [:]
        }
        
    }
}