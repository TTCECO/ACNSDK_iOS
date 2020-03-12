//
//  ACNSDK.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/2  下午5:59.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import TTCPay

@objc public enum ACNENV: Int32 {
    case develop = 1
    case product = 2
}

@objc public class ACNSDKError: NSObject {
    /// Error number
    @objc public var code: String = ""
    /// Error description
    @objc public var errorDescription: String = ""
}

@objc public class ACNUserInfo: NSObject {

    /// User ID
    @objc public let userId: String

    /// User Nickname
    @objc public var nickname: String?

    /// Avatar url
    @objc public var avatarUrl: String?

    /// gender   male / female
    @objc public var gender: String?

    /// phone number
    @objc public var telephone: String?

    /// mailbox
    @objc public var email: String?

    /// user's ACN Address
    @objc public var address: String?

    /// user's wallet Address
    @objc public var wallet: String?

    @objc public init(userId: String) {
        self.userId = userId
    }

    func copyItem() -> ACNUserInfo {

        let user = ACNUserInfo(userId: self.userId)
        user.nickname = self.nickname
        user.avatarUrl = self.avatarUrl
        user.gender = self.gender
        user.telephone = self.telephone
        user.email = self.email
        return user
    }
}

// MARK: - Initialize
public class ACNSDK: NSObject {

    /// Initialize SDK
    ///
    /// - Parameters:
    /// - appId: AppId assigned by the ACN platform, cannot be nil
    /// - secretKey: The SecretKey assigned by the ACN platform cannot be nil
    /// - scheme: Use the scheme, wallet jump dapp, scheme default is empty, if it is empty, it will not jump.
    /// - environment: set environment 1 - development 2 - production default=2
    /// - result:
    @objc public static func register(appId: String, secretKey: String, environment: ACNENV = .develop, result: ((Bool, ACNSDKError?) -> Void )? ) {
        
        setEnvironment(environment: environment)
        
        if !ACNManager.shared.SDKEnabled {
            result?(false, ACNSDKError(type: .SDKDisable))
            return
        }
        
        guard !appId.isEmpty else {
            result?(false, ACNSDKError(type: .APPIDNull))
            return
        }

        guard !secretKey.isEmpty else {
            result?(false, ACNSDKError(type: .SecretKeyNull))
            return
        }

        ACNManager.shared.register(appId: appId, secretKey: secretKey)
        result?(true, nil)
    
    }

    /// Enable SDK related functions
    ///
    /// - Parameter isEnabled: default is ture
    @objc(sdkEnabled:) public static func sdk(isEnabled: Bool) {

        ACNManager.shared.SDKEnabled = isEnabled
    }
    
    @objc(logEnabled:) public static func log(isEnabled: Bool) {
        
        ACNManager.shared.logEnable = isEnabled
    }
    
    /// set environment
    /// 1 - development 2 - production
    @objc static func setEnvironment(environment: ACNENV = .develop) {
        
        if environment == .product {
            acnServer = ACNServer(apiURL: "http://sdk-pro.ttcnet.io/", actionURL: "http://test.ttcnet.io/", ACNURL: "http://ttcnet.io/")
        } else {
            acnServer = ACNServer(apiURL: "http://sdk-ft.ttcnet.io/", actionURL: "http://test.ttcnet.io/", ACNURL: "http://test.ttcnet.io/")
        }
        
        ACNManager.shared.environment = Int32(environment.rawValue)
        TTCPay.setEnvironment(environment: Int32(environment.rawValue))
    }
    
    /// change Value to BigInt
    /// eg: ACNSDK.toBigIntString(value: "123.456", decimal: 18)   ==  "123456000000000000000"
    @objc static func toBigIntString(value: String, decimal: Int) -> String {
        return EtherNumberFormatter().number(from: value, decimals: decimal)?.description ?? "0"
    }
}

// MARK: - User
extension ACNSDK {

    /// login with userid
    ///
    /// - Parameters:
    /// - userInfo: User information, only userID is used
    /// - result:
    @objc public static func login(userInfo: ACNUserInfo, result: @escaping (Bool, ACNSDKError?, ACNUserInfo?) -> Void ) {

        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), nil)
            return
        }
        
        if userInfo.userId.isEmpty {
            result(false, ACNSDKError(type: .UserIDNull), nil)
            return
        }

        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), nil)
            return
        }

        ACNManager.shared.login(userInfo: userInfo.copyItem(), result: result)
    }

    /// Exit current user
    @objc public static func logout() {
        
        if !ACNManager.shared.SDKEnabled {
            return
        }
        
        ACNManager.shared.logout()
    }

    /// Update user information
    ///
    /// - Parameters:
    /// - userInfo: User information, the user information to be updated must be the current user
    /// - result:
    @objc(updateUserInfo:result:) public static func update(userInfo: ACNUserInfo, result: @escaping (Bool, ACNSDKError?, ACNUserInfo?) -> Void ) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), nil)
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), nil)
            return
        }
        
        if !ACNManager.shared.isLogin, ACNManager.shared.userInfo?.userId != userInfo.userId {
            result(false, ACNSDKError(type: .UserChanged), nil)
            return
        }

        ACNManager.shared.update(userInfo: userInfo.copyItem(), result: result)
    }

    /// Query the balance of current user's account
    ///
    /// - Parameter result: Return balance
    @objc public static func queryAccountBalance(result: @escaping (Bool, ACNSDKError?, String) -> Void ) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), "0")
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), "0")
            return
        }
        
        if ACNManager.shared.isLogin, ACNManager.shared.userInfo?.address != nil {
            ACNManager.shared.queryAccountBalance(resulted: result)
        } else {
            result(false, ACNSDKError(type: .LoginNo), "0")
        }
    }

    /// Query the TTC balance of the current user's wallet
    ///
    /// - Parameter result: Return balance
    @objc public static func queryWalletBalance(result: @escaping (Bool, ACNSDKError?, String) -> Void ) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), "0")
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), "0")
            return
        }
        
        if !ACNManager.shared.isLogin {
            result(false, ACNSDKError(type: .LoginNo), "0")
        } else if ACNManager.shared.userInfo?.wallet == nil {
            result(false, ACNSDKError(type: .Unbind), "0")
        } else {
            ACNManager.shared.queryWalletBalance(resulted: result)
        }

    }
    
    /// Query the ACN balance of the current user's wallet
    ///
    /// - Parameter result: Return balance
    @objc public static func queryWalletACNBalance(result: @escaping (Bool, ACNSDKError?, String) -> Void ) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), "0")
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), "0")
            return
        }
        
        if !ACNManager.shared.isLogin {
            result(false, ACNSDKError(type: .LoginNo), "0")
        } else if ACNManager.shared.userInfo?.wallet == nil {
            result(false, ACNSDKError(type: .Unbind), "0")
        } else {
            ACNManager.shared.queryWalletACNBalance(resulted: result)
        }
        
    }
    
    /// Query the current user's wallet address
    @objc public static func getBindWalletAddress(result: @escaping (Bool, ACNSDKError?, String?) -> Void ) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), nil)
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), nil)
            return
        }
        
        if !ACNManager.shared.isLogin {
            result(false, ACNSDKError(type: .LoginNo), nil)
        } else if ACNManager.shared.userInfo?.wallet == nil {
            result(false, ACNSDKError(type: .Unbind), nil)
        } else {
            result(true, nil, ACNManager.shared.userInfo?.wallet)
        }
    }
}

// MARK: - Binding wallet
extension ACNSDK {
    
    /// Needs to be used when bind app
    /// Call this method in the following methods
    /// (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
    /// or
    /// (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
    @discardableResult
    @objc public static func handleApplication(openURL: URL) -> Bool {

        if !ACNManager.shared.SDKEnabled {
            ACNPrint("ACN SDK not enabled")
            return false
        }

        guard let urlScheme = openURL.scheme, let urlHost = openURL.host, let query = openURL.query else {
            ACNPrint("url error")
            return false
        }

        let appScheme = "TTC-" + (Bundle.main.bundleIdentifier ?? "")
        if urlScheme != appScheme {
            ACNPrint("Not ACN Wallet")
            return false
        }

        let paramsArr = query.components(separatedBy: "&")
        var dict: [String: String] = [:]
        dict["wltScheme"] = urlHost
        for param in paramsArr {
            let arrP = param.components(separatedBy: "=")
            if arrP.count == 2 {
                dict[arrP.first ?? ""] = arrP.last ?? ""
            }
        }

        guard let address = dict["address"], !address.isEmpty else {
            ACNPrint("Address empty")
            return false
        }

        ACNManager.shared.handleWalletBind(params: dict)
        return true
    }

    /// Unbind the wallet that the current user has bound
    ///
    /// - Parameters:
    /// - result:
    @objc public static func unBindWallet(result: @escaping (Bool, ACNSDKError?) -> Void ) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable))
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo))
            return
        }
        
        guard let userId = ACNManager.shared.userInfo?.userId else {
            result(false, ACNSDKError(type: .LoginNo))
            return
        }

        guard ACNManager.shared.userInfo?.wallet != nil else {
            result(false, ACNSDKError(type: .Unbind))
            return
        }

        ACNManager.shared.unBindWallet(usetId: userId, result: result)
    }
    
    /// SDK bind wallet and block wallet's address
    @objc public static func bindWallet(iconUrl: String, result: @escaping (Bool, ACNSDKError?, _ address: String?) -> Void) {
        
        if !ACNManager.shared.SDKEnabled {
            result(false, ACNSDKError(type: .SDKDisable), nil)
            return
        }
        
        if ACNManager.shared.appId == nil
            || ACNManager.shared.appId.isEmpty
            || ACNManager.shared.secretKey == nil
            || ACNManager.shared.secretKey.isEmpty {
            result(false, ACNSDKError(type: .RegisterNo), nil)
            return
        }
        
        guard let _ = ACNManager.shared.userInfo?.userId else {
            result(false, ACNSDKError(type: .LoginNo), nil)
            return
        }
        
        ACNManager.shared.bindWallet(iconUrl: iconUrl, result: result)
    }
}
