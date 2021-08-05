platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

target 'ACNSDK' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    #protobuf
    pod 'SwiftProtobuf', '1.17.0'
    
    pod 'Alamofire', '5.4.3' #网络请求

    pod 'RealmSwift', '10.7.7' #数据库
    pod 'SwiftyRSA', '1.5.0'   #RSA加密签名等
    pod 'Google-Mobile-Ads-SDK'
    pod 'web3swift', :git => "https://github.com/skywinder/web3swift"
    pod 'GoogleMobileAdsMediationFacebook'
    
end

target 'ACN_SDK_iOS_Demo' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
end

target 'TTC_SDK_Pay_Demo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
end

target 'ACN_SDK_admob_Demo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'SnapKit'
  
end
#
#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
#      config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
#      config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'
#    end
#  end
#end
