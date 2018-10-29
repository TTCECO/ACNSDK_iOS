
Pod::Spec.new do |s|

  s.name         = "TTCSDK"
  s.version      = "0.0.10"
  s.summary      = "TTCSDK"
  s.homepage     = "https://github.com/TTCECO"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "chenchao" => "chenchao@tataufo.com" }

  s.ios.deployment_target = '9.0'
  s.swift_version    = "4.1"
  s.platform         = :ios
  s.ios.deployment_target = '9.0'

  s.source       = { :git => "https://github.com/TTCECO/TTCSDK_iOS.git", :tag => "#{s.version}" }
  s.source_files  = "TTCSDK/**/*.swift"
  s.resources = "TTCSDKBundle.bundle"
  s.frameworks = "Foundation", 'UIKit'
  s.vendored_frameworks = 'TTC_SDK_NET.framework'

  s.dependency 'SwiftProtobuf', '1.0.3'
  s.dependency 'BigInt', '3.1.0'
  s.dependency 'JSONRPCKit', '3.0.0'
  s.dependency 'APIKit', '~> 4.0.0'
  s.dependency 'CryptoSwift', '0.12.0'
  s.dependency 'TrustCore', '0.0.7'
  s.dependency 'TrezorCrypto', '0.0.6'
  s.dependency 'RealmSwift', '3.7.5'

end