Pod::Spec.new do |spec|
  spec.name         = "WalletSdk"
  spec.version      = "0.0.3"
  spec.summary      = "Swift Wallet SDK."
  spec.description  = <<-DESC
                   Swift Wallet SDK.
                   DESC
  spec.homepage     = "https://github.com/spruceid/wallet-sdk-swift"
  spec.license      = "MIT OR Apache-2.0"
  spec.author       = { "Spruce Systems, Inc." => "hello@spruceid.com" }
  spec.platform     = :ios

  spec.ios.deployment_target  = '13.0'

  spec.source        = { :git => "https://spruceid/wallet-sdk-swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/WalletSdk/*.swift"

  spec.static_framework = true
  spec.dependency 'WalletSdkRs' "~> 0.0.6"
  spec.dependency 'SwiftAlgorithm' "~> 1.0.0"
end
