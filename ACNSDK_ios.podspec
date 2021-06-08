Pod::Spec.new do |s|

  s.name         = "ACNSDK_ios"
  s.version      = "0.2.37"
  s.summary      = "ACNSDK"
  s.homepage     = "https://github.com/TTCECO"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "zhangliang" => "zhangliang@tataufo.com" }

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
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }

  s.dependency 'SwiftProtobuf', '1.17.0'
  s.dependency 'BigInt', '3.1.0'
  s.dependency 'JSONRPCKit'
  s.dependency 'Alamofire'
  s.dependency 'TrustCore', '0.0.7'
  s.dependency 'TrezorCrypto', '0.0.9'
  s.dependency 'RealmSwift'
  s.dependency 'SwiftyRSA'
  s.dependency 'Google-Mobile-Ads-SDK', '7.69'
  s.dependency 'web3swiftSuper.pod', '2.1.16'
  s.dependency 'PromiseKit', '6.8.4'
  s.dependency 'GoogleMobileAdsMediationFacebook', '5.6.0'

end
