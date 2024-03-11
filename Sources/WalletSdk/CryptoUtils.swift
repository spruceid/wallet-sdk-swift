import SpruceIDWalletSdkRs

public func pkcs8ToSec1(pem: String) throws  -> String {
    return try SpruceIDWalletSdkRs.pkcs8ToSec1(pem: pem)
}
public func sec1ToPkcs8(pem: String) throws  -> String {
    return try SpruceIDWalletSdkRs.sec1ToPkcs8(pem: pem)
}
