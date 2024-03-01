import CryptoKit
import Foundation

public class SoftECDSAPrivateSigningKey: PrivateKey, SigningKey, Jwk {
    private var innerKey: P256.Signing.PrivateKey
    var curve: Curve
    var xData: Data
    var yData: Data
    var dData: Data

    public var publicKey: some ECDSAPublicVerifyingKey {
        ECDSAPublicVerifyingKey(xData: xData, yData: yData, curve: curve)
    }

    var x963Represention: Data {
        self.innerKey.x963Representation
    }

    public var jwkRepresentation: [String: String] {
        return [
            "alg": Alg.ellipticCurve.jwaRepresentation,
            "crv": curve.jwaRepresentation,
            "x": xData.base64EncodedUrlSafe,
            "y": yData.base64EncodedUrlSafe,
            "d": dData.base64EncodedUrlSafe
        ]
    }

    @available(iOS 14, *)
    public init?(pkcs8Representation: String, curve: Curve) throws {
        self.curve = curve
        self.innerKey = try P256.Signing.PrivateKey(pemRepresentation: pkcs8Representation)
        guard let components = ECPrivateKeyComponents(
            x963Representation: self.innerKey.x963Representation, curve: curve) else {
            return nil
        }

        self.xData = components.xData
        self.yData = components.yData
        self.dData = components.dData
    }

    public init(jwkRepresentation: [String: String]) throws {
        guard let alg = jwkRepresentation["alg"] else {
            throw JwkParseError.missingProperty("alg")
        }

        if alg != Alg.ellipticCurve.jwaRepresentation {
            throw JwkParseError.unknownProperty("alg", alg)
        }

        guard let crv = jwkRepresentation["crv"] else {
            throw JwkParseError.missingProperty("crv")
        }

        guard let curve = Curve.init(jwaRepresentation: crv) else {
            throw JwkParseError.unknownProperty("crv", crv)
        }

        let xData = try parseBase64Bytes(jwk: jwkRepresentation, propName: "x")
        let yData = try parseBase64Bytes(jwk: jwkRepresentation, propName: "y")
        let dData = try parseBase64Bytes(jwk: jwkRepresentation, propName: "d")

        guard let components = ECPrivateKeyComponents(curve: curve, xData: xData, yData: yData, dData: dData) else {
            throw JwkParseError.wrongKeyLength
        }

        self.innerKey = try P256.Signing.PrivateKey(x963Representation: components.x963Representation)
        self.curve = curve
        self.xData = xData
        self.yData = yData
        self.dData = dData
    }

    public func signature(data: Data) throws -> Data {
        try self.innerKey.signature(for: data).rawRepresentation
    }
}

public class ECDSAPublicVerifyingKey: PublicKey {
    var xData: Data
    var yData: Data
    var curve: Curve

    init(xData: Data, yData: Data, curve: Curve) {
        self.xData = xData
        self.yData = yData
        self.curve = curve
    }

    public var jwkRepresentation: [String: String] {
        return [
            "alg": Alg.ellipticCurve.jwaRepresentation,
            "crv": curve.jwaRepresentation,
            "x": xData.base64EncodedUrlSafe,
            "y": yData.base64EncodedUrlSafe
        ]
    }
}
