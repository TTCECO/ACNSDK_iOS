
Pod::Spec.new do |s|

  s.name         = "ACNSDK"
  s.version      = "0.2.26"
  s.summary      = "ACNSDK"
  s.homepage     = "https://github.com/TTCECO"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "chenchao" => "chenchao@tataufo.com" }

  s.ios.deployment_target = '9.0'
  s.swift_version    = "4.2"
  s.platform         = :ios
  s.ios.deployment_target = '9.0'

  s.source       = { :git => "https://github.com/TTCECO/ACNSDK_iOS.git", :tag => "#{s.version}" }
  s.source_files  = "ACNSDK/**/*.swift"
  s.resources = "ACNSDKBundle.bundle"
  s.frameworks = "Foundation", 'UIKit'
  s.vendored_frameworks = 'ACN_SDK_NET.framework', 'TTCPay.framework'
  s.static_framework = true

  s.dependency 'SwiftProtobuf', '1.0.3'
  s.dependency 'BigInt', '3.1.0'
  s.dependency 'JSONRPCKit'
  s.dependency 'Alamofire'
  s.dependency 'TrustCore', '0.0.7'
  s.dependency 'TrezorCrypto', '0.0.9'
  s.dependency 'RealmSwift'
  s.dependency 'SwiftyRSA'
  s.dependency 'Google-Mobile-Ads-SDK'
  s.dependency 'web3swift.pod', '2.1.5'
  s.dependency 'PromiseKit', '6.8.0'
  s.dependency 'GoogleMobileAdsMediationFacebook', '5.6.0'
	
end
