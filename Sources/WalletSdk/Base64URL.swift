import Foundation

extension Data {
  var base64EncodedUrlSafe: String {
    let string = self.base64EncodedString()
    
    // Make this URL safe and remove padding
    return string
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

extension Data {
  init?(base64EncodedURLSafe string: String, options: Base64DecodingOptions = []) {
    let string = string
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

    self.init(base64Encoded: string, options: options)
  }
}
