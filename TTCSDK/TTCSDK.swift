//
//  TTCSDK.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/2  下午5:59.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import TTCPay

@objc public class TTCSDKError: NSObject {
    /// Error number
    @objc public var code: String = ""
    /// Error description
    @objc public var errorDescription: String = ""
}

@objc public class TTCUserInfo: NSObject {

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

    /// user's TTC Address
    @objc public var address: String?

    /// user's wallet Address
    @objc public var wallet: String?

    @objc public init(userId: String) {
        self.userId = userId
    }

    func copyItem() -> TTCUserInfo {

        let user = TTCUserInfo(userId: self.userId)
        user.nickname = self.nickname
        user.avatarUrl = self.avatarUrl
        user.gender = self.gender
        user.telephone = self.telephone
        user.email = self.email
        return user
    }
}

// MARK: - Initialize
public class TTCSDK: NSObject {

    /// Initialize SDK
    ///
    /// - Parameters:
    /// - appId: AppId assigned by the TTC platform, cannot be nil
    /// - secretKey: The SecretKey assigned by the TTC platform cannot be nil
    /// - scheme: Use the scheme, wallet jump dapp, scheme default is empty, if it is empty, it will not jump.
    /// - environment: set environment 1 - development 2 - production default=2
    /// - result:
    @objc public static func register(appId: String, secretKey: String, environment: Int = 2, result: ((Bool, TTCSDKError?) -> Void )? ) {
        
        setEnvironment(environment: environment)
        
        if !TTCManager.shared.SDKEnabled {
            result?(false, TTCSDKError(type: .SDKDisable))
            return
        }
        
        guard !appId.isEmpty else {
            result?(false, TTCSDKError(type: .APPIDNull))
            return
        }

        guard !secretKey.isEmpty else {
            result?(false, TTCSDKError(type: .SecretKeyNull))
            return
        }

        TTCManager.shared.register(appId: appId, secretKey: secretKey)
        result?(true, nil)
    
    }

    /// Enable SDK related functions
    ///
    /// - Parameter isEnabled: default is ture
    @objc(sdkEnabled:) public static func sdk(isEnabled: Bool) {

        TTCManager.shared.SDKEnabled = isEnabled
    }
    
    @objc(logEnabled:) public static func log(isEnabled: Bool) {
        
        TTCManager.shared.logEnable = isEnabled
    }
    
    /// set environment
    /// 1 - development 2 - production
    static func setEnvironment(environment: Int = 2) {
        
        if environment == 2 {
            ttcServer = TTCServer(apiURL: "http://sdk.ttcnet.io/", actionURL: "http://test.ttcnet.io/", TTCURL: "http://ttcnet.io/")
        } else {
            ttcServer = TTCServer(apiURL: "http://sdk-ft.ttcnet.io/", actionURL: "http://test.ttcnet.io/", TTCURL: "http://test.ttcnet.io/")
        }
        
        TTCPay.setEnvironment(environment: environment)
    }
}

// MARK: - User
extension TTCSDK {

    /// login with userid
    ///
    /// - Parameters:
    /// - userInfo: User information, only userID is used
    /// - result:
    @objc public static func login(userInfo: TTCUserInfo, result: @escaping (Bool, TTCSDKError?, TTCUserInfo?) -> Void ) {

        if !TTCManager.shared.SDKEnabled {
            result(false, TTCSDKError(type: .SDKDisable), nil)
            return
        }
        
        if userInfo.userId.isEmpty {
            result(false, TTCSDKError(type: .UserIDNull), nil)
            return
        }

        if TTCManager.shared.appId == nil
            || TTCManager.shared.appId.isEmpty
            || TTCManager.shared.secretKey == nil
            || TTCManager.shared.secretKey.isEmpty {
            result(false, TTCSDKError(type: .RegisterNo), nil)
            return
        }

        TTCManager.shared.login(userInfo: userInfo.copyItem(), result: result)
    }

    /// Exit current user
    @objc public static func logout() {
        
        if !TTCManager.shared.SDKEnabled {
            return
        }
        
        TTCManager.shared.logout()
    }

    /// Update user information
    ///
    /// - Parameters:
    /// - userInfo: User information, the user information to be updated must be the current user
    /// - result:
    @objc(updateUserInfo:result:) public static func update(userInfo: TTCUserInfo, result: @escaping (Bool, TTCSDKError?, TTCUserInfo?) -> Void ) {
        
        if !TTCManager.shared.SDKEnabled {
            result(false, TTCSDKError(type: .SDKDisable), nil)
            return
        }
        
        if TTCManager.shared.appId == nil
            || TTCManager.shared.appId.isEmpty
            || TTCManager.shared.secretKey == nil
            || TTCManager.shared.secretKey.isEmpty {
            result(false, TTCSDKError(type: .RegisterNo), nil)
            return
        }
        
        if !TTCManager.shared.isLogin, TTCManager.shared.userInfo?.userId != userInfo.userId {
            result(false, TTCSDKError(type: .UserChanged), nil)
            return
        }

        TTCManager.shared.update(userInfo: userInfo.copyItem(), result: result)
    }

    /// Query the balance of current user's account
    ///
    /// - Parameter result: Return balance
    @objc public static func queryAccountBalance(result: @escaping (Bool, TTCSDKError?, String) -> Void ) {
        
        if !TTCManager.shared.SDKEnabled {
            result(false, TTCSDKError(type: .SDKDisable), "0")
            return
        }
        
        if TTCManager.shared.appId == nil
            || TTCManager.shared.appId.isEmpty
            || TTCManager.shared.secretKey == nil
            || TTCManager.shared.secretKey.isEmpty {
            result(false, TTCSDKError(type: .RegisterNo), "0")
            return
        }
        
        if TTCManager.shared.isLogin, TTCManager.shared.userInfo?.address != nil {
            TTCManager.shared.queryAccountBalance(resulted: result)
        } else {
            result(false, TTCSDKError(type: .LoginNo), "0")
        }
    }

    /// Query the balance of the current user's wallet
    ///
    /// - Parameter result: Return balance
    @objc public static func queryWalletBalance(result: @escaping (Bool, TTCSDKError?, String) -> Void ) {
        
        if !TTCManager.shared.SDKEnabled {
            result(false, TTCSDKError(type: .SDKDisable), "0")
            return
        }
        
        if TTCManager.shared.appId == nil
            || TTCManager.shared.appId.isEmpty
            || TTCManager.shared.secretKey == nil
            || TTCManager.shared.secretKey.isEmpty {
            result(false, TTCSDKError(type: .RegisterNo), "0")
            return
        }
        
        if !TTCManager.shared.isLogin {
            result(false, TTCSDKError(type: .LoginNo), "0")
        } else if TTCManager.shared.userInfo?.wallet == nil {
            result(false, TTCSDKError(type: .Unbind), "0")
        } else {
            TTCManager.shared.queryWalletBalance(resulted: result)
        }

    }
}

// MARK: - Binding wallet
extension TTCSDK {
    
    /// Needs to be used when bind app
    /// Call this method in the following methods
    /// (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
    /// or
    /// (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
    @discardableResult
    @objc public static func handleApplication(openURL: URL) -> Bool {

        if !TTCManager.shared.SDKEnabled {
            TTCPrint("TTC SDK not enabled")
            return false
        }

        guard let urlScheme = openURL.scheme, let urlHost = openURL.host, let query = openURL.query else {
            TTCPrint("url error")
            return false
        }

        let appScheme = "TTC-" + (Bundle.main.bundleIdentifier ?? "")
        if urlScheme != appScheme || !urlHost.hasPrefix("TTCWallet") {
            TTCPrint("Not TTC Wallet")
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
            TTCPrint("Address empty")
            return false
        }

        TTCManager.shared.handleWalletBind(params: dict)
        return true
    }

    /// Unbind the wallet that the current user has bound
    ///
    /// - Parameters:
    /// - result:
    @objc public static func unBindWallet(result: @escaping (Bool, TTCSDKError?) -> Void ) {
        
        if !TTCManager.shared.SDKEnabled {
            result(false, TTCSDKError(type: .SDKDisable))
            return
        }
        
        if TTCManager.shared.appId == nil
            || TTCManager.shared.appId.isEmpty
            || TTCManager.shared.secretKey == nil
            || TTCManager.shared.secretKey.isEmpty {
            result(false, TTCSDKError(type: .RegisterNo))
            return
        }
        
        guard let userId = TTCManager.shared.userInfo?.userId else {
            result(false, TTCSDKError(type: .LoginNo))
            return
        }

        guard TTCManager.shared.userInfo?.wallet != nil else {
            result(false, TTCSDKError(type: .Unbind))
            return
        }

        TTCManager.shared.unBindWallet(usetId: userId, result: result)
    }
}
