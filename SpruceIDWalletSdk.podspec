Pod::Spec.new do |spec|
  spec.name         = "SpruceIDWalletSdk"
  spec.version      = "0.0.6"
  spec.summary      = "Swift Wallet SDK."
  spec.description  = <<-DESC
                   SpruceID Swift Wallet SDK.
                   DESC
  spec.homepage     = "https://github.com/spruceid/wallet-sdk-swift"
  spec.license      = { :type => "MIT & Apache License, Version 2.0", :text => <<-LICENSE
                          Refer to LICENSE-MIT and LICENSE-APACHE in the repository.
                        LICENSE
                      }
  spec.author       = { "Spruce Systems, Inc." => "hello@spruceid.com" }
  spec.platform     = :ios
  spec.swift_version = '5.9'

  spec.ios.deployment_target  = '13.0'

  spec.source        = { :git => "https://github.com/spruceid/wallet-sdk-swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/WalletSdk/*.swift"

  spec.static_framework = true
  spec.dependency 'SpruceIDWalletSdkRs', "~> 0.0.24"
  spec.dependency 'SwiftAlgorithms', "~> 1.0.0"
  spec.frameworks = 'Foundation', 'CoreBluetooth', 'CryptoKit'
end
