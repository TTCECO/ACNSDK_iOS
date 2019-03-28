platform :ios, '9.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

target 'TTCSDK' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    #protobuf
    pod 'SwiftProtobuf', '1.0.3'
    
    pod 'BigInt', '~> 3.0' # 任意宽度整数
    pod 'JSONRPCKit' #RPC json库
    pod 'Alamofire' #网络请求
    pod 'CryptoSwift', '0.12.0'#加密库
    pod 'TrustCore', '~> 0.0.7'
    pod 'TrezorCrypto', '0.0.9'
    pod 'RealmSwift', '3.7.5' #数据库
    pod 'SwiftyRSA'   #RSA加密签名等
    pod 'Google-Mobile-Ads-SDK', '7.37.0'
    
    #代码格式工具
    pod 'SwiftLint', '0.28.1'
end

target 'TTC_SDK_iOS_Demo' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
end

target 'TTC_SDK_Pay_Demo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
end

target 'TTC_SDK_admob_Demo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'SnapKit'
  
end
