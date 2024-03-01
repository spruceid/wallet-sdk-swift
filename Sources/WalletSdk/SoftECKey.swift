import CryptoKit
import Foundation

public class SoftECDSAPrivateSigningKey: PrivateKey, SigningKey, Jwk {
    private var innerKey: P256.Signing.PrivateKey
    var curve: Curve
    var x: Data
    var y: Data
    var d: Data
    
    var publicKey: some ECDSAPublicVerifyingKey {
        ECDSAPublicVerifyingKey(x: x, y: y, curve: curve)
    }
    
    var x963Represention: Data {
        self.innerKey.x963Representation
    }
    
    var jwkRepresentation: [String : String] {
        return [
            "alg": Alg.ellipticCurve.jwaRepresentation,
            "crv": curve.jwaRepresentation,
            "x": x.base64EncodedUrlSafe,
            "y": y.base64EncodedUrlSafe,
            "d": d.base64EncodedUrlSafe,
        ]
    }
    
    @available(iOS 14, *)
    init?(pkcs8Representation: String, curve: Curve) throws {
        self.curve = curve
        self.innerKey = try P256.Signing.PrivateKey(pemRepresentation: pkcs8Representation)
        guard let components = ECPrivateKeyComponents(x963Representation: self.innerKey.x963Representation, curve: curve) else {
            return nil
        }
        
        self.x = components.x;
        self.y = components.y;
        self.d = components.d;
    }
    
    init(jwkRepresentation: [String: String]) throws {
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
        
        let x = try parseBase64Bytes(jwk: jwkRepresentation, propName: "x");
        let y = try parseBase64Bytes(jwk: jwkRepresentation, propName: "y");
        let d = try parseBase64Bytes(jwk: jwkRepresentation, propName: "d");
        
        guard let components = ECPrivateKeyComponents(curve: curve, x: x, y: y, d: d) else {
            throw JwkParseError.wrongKeyLength
        }

        self.innerKey = try P256.Signing.PrivateKey(x963Representation: components.x963Representation)
        self.curve = curve
        self.x = x
        self.y = y
        self.d = d
    }
    
    func signature(data: Data) throws -> Data {
        try self.innerKey.signature(for: data).rawRepresentation
    }
}

public class ECDSAPublicVerifyingKey: PublicKey {
    var x: Data
    var y: Data
    var curve: Curve
    
    init(x: Data, y: Data, curve: Curve) {
        self.x = x
        self.y = y
        self.curve = curve
    }

    var jwkRepresentation: [String: String] {
        return [
            "alg": Alg.ellipticCurve.jwaRepresentation,
            "crv": curve.jwaRepresentation,
            "x": x.base64EncodedUrlSafe,
            "y": y.base64EncodedUrlSafe,
        ]
    }
}
