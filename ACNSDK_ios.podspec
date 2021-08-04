Pod::Spec.new do |s|

  s.name         = "ACNSDK_ios"
  s.version      = "0.2.40"
  s.summary      = "ACNSDK"
  s.homepage     = "https://github.com/TTCECO"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "zhangliang" => "zhangliang@tataufo.com" }

  s.ios.deployment_target = '10.0'
  s.swift_version    = "5.4"
  s.platform         = :ios
  s.ios.deployment_target = '10.0'

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
  s.dependency 'Alamofire', '5.4.3'
  s.dependency 'RealmSwift', '5.5.1'
  s.dependency 'SwiftyRSA', '1.5.0'
  s.dependency 'Google-Mobile-Ads-SDK', '8.8.0'
  s.dependency 'web3swift', '2.3.0'
  s.dependency 'GoogleMobileAdsMediationFacebook', '6.5.1.0'

end
