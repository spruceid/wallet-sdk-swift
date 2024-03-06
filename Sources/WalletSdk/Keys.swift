import Foundation

protocol Jwa {
    var jwaRepresentation: String { get }
}

enum Alg: Jwa {
    case ellipticCurve

    var jwaRepresentation: String {
        switch self {
        case .ellipticCurve:
            "EC"
        }
    }
}

public protocol Jwk {
    var jwkRepresentation: [String: String] { get }
}

public protocol SigningKey {
    func signature(data: Data) throws -> Data
}

public protocol PrivateKey {
    associatedtype PublicKeyKind: PublicKey
    var publicKey: PublicKeyKind { get }
}

public protocol PublicKey: Jwk {
}

enum JwkParseError: Error {
    case missingProperty(String)
    case unknownProperty(String, String)
    case base64Parse(String)
    case wrongKeyLength
}

public enum Curve: Jwa {
    case p256

    init?(jwaRepresentation: String) {
        switch jwaRepresentation {
        case "P-256":
            self = .p256
        default:
            return nil
        }
    }

    var jwaRepresentation: String {
        switch self {
        case .p256:
            return "P-256"
        }
    }

    var keyComponentOctets: Int {
        switch self {
        case .p256:
            return 32
        }
    }
}

internal class ECPrivateKeyComponents {
    var curve: Curve
    var xData: Data
    var yData: Data
    var dData: Data

    let x963Header: UInt8 = 0x04
    let x963HeaderLen: Int = 1

    init?(curve: Curve, xData: Data, yData: Data, dData: Data) {
        if xData.count != curve.keyComponentOctets {
            return nil
        }

        if yData.count != curve.keyComponentOctets {
            return nil
        }

        if dData.count != curve.keyComponentOctets {
            return nil
        }

        self.curve = curve
        self.xData = xData
        self.yData = yData
        self.dData = dData
    }

    init?(x963Representation: Data, curve: Curve) {
        let x963BufSize = x963HeaderLen + (3 * curve.keyComponentOctets)
        if x963Representation.count != x963BufSize {
            return nil
        }

        let xOffset = x963HeaderLen
        let xEnd = xOffset + curve.keyComponentOctets
        let yOffset = xEnd
        let yEnd = yOffset + curve.keyComponentOctets
        let dOffset = yEnd
        let dEnd = dOffset + curve.keyComponentOctets

        self.curve = curve
        self.xData = x963Representation.subdata(in: xOffset..<xEnd)
        self.yData = x963Representation.subdata(in: yOffset..<yEnd)
        self.dData = x963Representation.subdata(in: dOffset..<dEnd)
    }

    var x963Representation: Data {
        assert(self.xData.count == curve.keyComponentOctets)
        assert(self.yData.count == curve.keyComponentOctets)
        assert(self.dData.count == curve.keyComponentOctets)

        var buffer = Data()

        buffer.append(x963Header)
        buffer.append(self.xData)
        buffer.append(self.yData)
        buffer.append(self.dData)

        return buffer
    }
}

internal func parseBase64Bytes(jwk: [String: String], propName: String) throws -> Data {
    guard let base64String = jwk[propName] else {
        throw JwkParseError.missingProperty(propName)
    }

    guard let data = Data(base64EncodedURLSafe: base64String) else {
        throw JwkParseError.base64Parse(propName)
    }

    return data
}
