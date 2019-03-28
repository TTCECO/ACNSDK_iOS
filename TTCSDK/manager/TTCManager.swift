//
//  TTCManager.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/2  下午4:22.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import CryptoSwift
import BigInt
import TTC_SDK_NET
import TTCPay

internal class TTCManager {

    static let shared = TTCManager()
    /// Dapp Private key
    var privateKey: String?
    /// Dapp address
    var actionAddress: String?
    var isRequestPrivatekey: Bool = false

    // MARK: - register -
    var appId: String!
    var secretKey: String!
    var isRegister: Bool = false

    // MARK: - user -
    var userInfo: TTCUserInfo?
    var isLogin: Bool = false

    // MARK: - bind -
    let DAPP = ["com.tataufo.TTC-SDK-iOS-Demo"]
    var walletAddress: String?
    var walletScheme: String?
    var walletLanguage: String = "en"
    var reward: Int = 0

    /// SDK is available
    var SDKEnabled: Bool = true {
        didSet {
            if !SDKEnabled {
                TTCActionManager.shared.timer?.invalidate()
            } else {
                if TTCManager.shared.isLogin {
                    TTCActionManager.shared.timer?.invalidate()
                    TTCActionManager.shared.timer = nil
                    TTCActionManager.shared.runScheduledTimer()
                }
            }
        }
    }
    /// SDK is log
    var logEnable: Bool = false
    // location
    let location = TTCLocationManager()
    
    /// Register to start the SDK
    func register(appId: String, secretKey: String) {

        self.appId = appId
        self.secretKey = secretKey
        TTCPrint("===========================start===========================")
        TTCPrint("Startup completed appId: \(appId),secretKey: \(secretKey)")
        TTCPrint("TTCSDK version: \(SDKVersion)")
        
        TTCNetManager.shared.appId = appId
        TTCNetManager.shared.secretKey = secretKey
        TTCNetManager.shared.SDKVersion = SDKVersion
        TTCNetManager.shared.apiURL = ttcServer.apiURL
        
        TTCPay.shared.appId = appId
        TTCPay.shared.secretKey = secretKey
        TTCPay.shared.apiURL = ttcServer.apiURL
        
        // get chainID
//        TTCActionManager.shared.getChainID()
        // Open positioning
        location.locate()
    }
}

// MARK: - user -
extension TTCManager {

    func setDefault() {
        
        userInfo = nil
        privateKey = ""
        actionAddress = ""
        isRequestPrivatekey = false
        
        isRegister = false
        isLogin = false
        
        TTCActionManager.shared.timer?.invalidate()
    }
    
    @objc func becomeActive() {
        TTCPrint("becomeActive")
        
        if !TTCManager.shared.SDKEnabled {
            return
        }
        
        let time: TimeInterval = Date().timeIntervalSince1970
        let currentDay = Int(ceil(time/86400))
        
        if UserDefaults.lastDayNumber < currentDay {
            TTCUploadAction.uploadAction(actionType: actionTypeLogin, extra: "") { (success, error) in
                if success {
                    UserDefaults.lastDayNumber = currentDay
                }
            }
        }
    }
    
    func login(userInfo: TTCUserInfo, result: @escaping (Bool, TTCSDKError?, TTCUserInfo?) -> Void) {
        
        setDefault()
        
        self.userInfo = userInfo
        
        TTCNetManager.shared.userID = userInfo.userId
        
        TTCActionManager.shared.timer?.invalidate()
        requestRegisterUser(result: { (success, error) -> Void in
            
            self.isLogin = success
            
            if success {
                
                TTCPrint("login successful userId: \(String(describing: self.userInfo?.userId))")
                result(true, nil, self.userInfo)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
                
                TTCActionManager.shared.setDefaultManager()
                self.requestPrivateKeyAndAddressRetry()
                
            } else {
                
                result(false, TTCSDKError(error: error), nil)
                TTCPrint("Login failed: \(String(describing: error?.errorDescription))")
            }
        })
    }

    func logout() {

        TTCPrint("sign out")
        /// user logout
        setDefault()
        NotificationCenter.default.removeObserver(self)
        
    }

    func update(userInfo: TTCUserInfo, result: @escaping (Bool, TTCSDKError?, TTCUserInfo?) -> Void) {
        
        let userid = TTCManager.shared.userInfo?.userId

        var kvInfoArr: [TTCNETKVInfo] = []
        
        let kvInfo = TTCNETKVInfo()
        kvInfo.key = "userId"
        kvInfo.value = userInfo.userId
        kvInfoArr.append(kvInfo)
        
        if let nickname = userInfo.nickname {
            let kvInfo = TTCNETKVInfo()
            kvInfo.key = "nickname"
            kvInfo.value = nickname
            kvInfoArr.append(kvInfo)
        }
        if let avatarUrl = userInfo.avatarUrl {
            let kvInfo = TTCNETKVInfo()
            kvInfo.key = "avatarUrl"
            kvInfo.value = avatarUrl
            kvInfoArr.append(kvInfo)
        }
        if let gender = userInfo.gender {
            let kvInfo = TTCNETKVInfo()
            kvInfo.key = "gender"
            kvInfo.value = gender
            kvInfoArr.append(kvInfo)
        }
        if let telephone = userInfo.telephone {
            let kvInfo = TTCNETKVInfo()
            kvInfo.key = "telephone"
            kvInfo.value = telephone
            kvInfoArr.append(kvInfo)
        }
        
        if let email = userInfo.email {
            let kvInfo = TTCNETKVInfo()
            kvInfo.key = "email"
            kvInfo.value = email
            kvInfoArr.append(kvInfo)
        }
        
        /// Update info
        TTCNetworkManager.updateUserInfo(InfoArr: kvInfoArr) { (success, error, userInfoList) -> Void in

            if success {
                
                if userid != TTCManager.shared.userInfo?.userId {
                    result(false, TTCSDKError(type: .UserChanged), nil)
                    return
                }
                
                self.userInfo = userInfo
                
                guard let list = userInfoList else {
                    TTCPrint("Update user information successfully, but return data is null")
                    result(true, nil, self.userInfo)
                    return
                }
                for kvInfo in list {
                    if kvInfo.key == "wallet" {
                        self.userInfo?.wallet = kvInfo.value
                    } else if kvInfo.key == "address" {
                        self.userInfo?.address = kvInfo.value
                    }
                }
                TTCPrint("Update user information successfully")
                result(true, nil, self.userInfo)
            } else {
                TTCPrint("Update user information faile: \(String(describing: error?.errorDescription))")
                result(false, TTCSDKError(error: error), nil)
            }
        }
    }
    
    /// query account balance
    func queryAccountBalance(resulted: @escaping (Bool, TTCSDKError?, String) -> Void) {
        
        TTCRPCManager.getEthBalance(for: self.userInfo?.address ?? "") { (result) in
            switch result {
            case .success(let balance):
                TTCPrint("query account balance successfully, balance: \(balance.amountFull)")
                resulted(true, nil, balance.amountFull)
            case .failure(let error):
                TTCPrint("query account balance faile: \(error)")
                resulted(false, TTCSDKError(description: String(describing: error)), "0")
            }
        }
    }
    
    /// query wallet balance
    func queryWalletBalance(resulted: @escaping (Bool, TTCSDKError?, String) -> Void) {
        
        TTCRPCManager.getEthBalance(for: self.userInfo?.wallet ?? "") { (result) in
            switch result {
            case .success(let balance):
                TTCPrint("query wallet balance successfully, balance: \(balance.amountFull)")
                resulted(true, nil, balance.amountFull)
            case .failure(let error):
                TTCPrint("query wallet balance faile: \(error)")
                resulted(false, TTCSDKError(description: String(describing: error)), "0")
            }
        }
    }
    
    /// handle user action
    func handleUserActionInfo(actionType: Int32, extra: String) {
        
        let actionInfo = TTCActionInfo()
        actionInfo.actionType = actionType
        actionInfo.fromUserID = self.userInfo?.userId ?? ""
        actionInfo.extra = extra
        
        TTCActionManager.shared.insertAction(actionInfo: actionInfo)
        
        if !self.isRegister {
            requestPrivateKeyAndAddressRetry()
        }
    }
}

// MARK: - bind -
extension TTCManager {
    
    /// Wallet binding
    func handleWalletBind(params: [String: String]) {

        self.walletAddress = params["address"]
        self.walletScheme = params["wltScheme"]
        self.walletLanguage = params["language"] ?? "en"
        self.reward = Int(params["reward"] ?? "0") ?? 0

        if self.isLogin {
            TTCPrint("bind - go to binding page")
            let bindVC = TTCBindViewController(language: self.walletLanguage)
            TTCWindow.shared.rootViewController?.present(bindVC, animated: true, completion: nil)
        } else {
            TTCPrint("bind - User not login")
        }
    }

    /// back wallet -1 cancel， 0 faile，1 success，
    func backWallet(bindState: Int) {
        
        let walletUrlStr = (self.walletScheme ?? "") + "://Bind?bundleID=\(Bundle.main.bundleIdentifier ?? "")&bindState=\(bindState)&reward=\(TTCManager.shared.reward)"
        let walletUrl = URL(string: walletUrlStr)

        guard let wltUrl = walletUrl else { return }

        if !UIApplication.shared.openURL(wltUrl) {
            TTCPrint("bind - Return failure")
        }
    }

    func unBindWallet(usetId: String, result: @escaping (Bool, TTCSDKError?) -> Void) {

        let userid = TTCManager.shared.userInfo?.userId
        
        TTCNetworkManager.bindingDapp(isBind: false, walletAddress: self.userInfo?.wallet ?? "") { (success, error) -> Void in

            if success {
                
                if userid != TTCManager.shared.userInfo?.userId {
                    result(false, TTCSDKError(type: .UserChanged))
                    return
                }
                
                self.userInfo?.wallet = nil
                TTCPrint("Unbind wallet successfully")
                result(true, nil)
            } else {
                TTCPrint("Unbind wallet failed: \(String(describing: error?.errorDescription))")
                result(false, TTCSDKError(error: error))
            }
        }
    }
}

// MARK: - net -
extension TTCManager {
    
    /// Request private key to automatically re-request if it fails. Up to five times
    /// get privateKey,address,gas price,gas limit,
    func requestPrivateKeyAndAddressRetry() {

        if !self.isLogin {
            return
        }

        requestPrivateKeyAndAddress { (success, error) -> Void in
            
            self.isRegister = success
            if success {
                self.becomeActive()
                TTCActionManager.shared.getChainID()
                TTCActionManager.shared.getTransactionCount()
            } else {
                if error != nil {
                    switch error {
                    case .requesting?:
                        return
                    default: break
                    }
                }
            }
        }
    }

    func requestPrivateKeyAndAddress(result: @escaping (Bool, TTCInternalError?) -> Void) {

        if self.isRequestPrivatekey {
            result(false, .requesting)
            return
        }
        
        let userid = TTCManager.shared.userInfo?.userId
        self.isRequestPrivatekey = true
        
        /// Get the private key used by Dapp uploading behavior, decrypt with Dapp's secretKey
        TTCNetworkManager.getBaseInfo { (success, error, dataMessage) -> Void in
            self.isRequestPrivatekey = false
            
            if success {
                
                guard let data = dataMessage else {
                    result(false, .responseDataParseError)
                    return
                }
                
                if !data.sideChainRpcurl.isEmpty, !data.mainChainRpcurl.isEmpty {
                    ttcServer = TTCServer(apiURL: ttcServer.apiURL, actionURL: data.sideChainRpcurl, TTCURL: data.mainChainRpcurl)
                }
                
                if !data.uploadOperationLogGasPrice.isEmpty, data.uploadOperationLogGasLimit != 0 {
                    TTCActionManager.shared.gasPrice = BigInt(data.uploadOperationLogGasPrice) ?? BigInt("500000000000")
                    TTCActionManager.shared.gasLimit = BigInt(data.uploadOperationLogGasLimit)
                }

                guard let encodePrivateKey = dataMessage?.encodePrivateKey, let dappActionAddress = dataMessage?.dappActionAddress else {
                    TTCPrint("Private key is empty")
                    result(false, .responseDataParseError)
                    return
                }
                
                guard let baseData = Data(base64Encoded: encodePrivateKey, options: []), baseData.count > 16 else {
                    TTCPrint("Private key failed to data")
                    result(false, .responseDataParseError)
                    return
                }

                let bytes: [UInt8] = Array(baseData)
                let iv: [UInt8] = Array(bytes.prefix(16))
                let crypted: [UInt8] = Array(bytes.suffix(bytes.count - 16))
                let secretKey: [UInt8] = Array(self.secretKey.utf8)

                do {
                    var decrypted = try AES(key: secretKey, blockMode: CBC(iv: iv), padding: .zeroPadding).decrypt(crypted)
                    if let padding = decrypted.last {
                        let length = decrypted.count - Int(padding)
                        decrypted = Array(decrypted.prefix(length))
                    }

                    let keyData = Data(bytes: decrypted)
                    guard let privateKey = String(data: keyData, encoding: .utf8) else {
                        TTCPrint("Private key failed to string")
                        result(false, .responseDataParseError)
                        return
                    }
                    
                    if userid != TTCManager.shared.userInfo?.userId {
                        result(false, .responseDataParseError)
                        return
                    }
                    
                    self.privateKey = privateKey
                    self.actionAddress = dappActionAddress
                    TTCPrint("Request private key success, actionAddress: \(dappActionAddress)")
                    result(true, nil)
                } catch {
                    TTCPrint("Failed to decrypt the private key: \(error)")
                    result(false, .responseDataParseError)
                }

            } else {
                TTCPrint("Failed to get the private key: \(String(describing: error))")
                guard let err = error else {
                    result(false, .responseDataParseError)
                    return
                }
                result(false, err)
            }
        }
    }

    func requestRegisterUser(result: @escaping (Bool, TTCInternalError?) -> Void) {

        TTCNetworkManager.registerUser { (success, error, dataMessage) -> Void in

            if success, let data = dataMessage {
                var isHashUnique = false
                var isHashPosition = false
                
                for KVInfo in data {
                    if KVInfo.key == "wallet", !KVInfo.value.isEmpty {
                        self.userInfo?.wallet = KVInfo.value
                    } else if KVInfo.key == "address", !KVInfo.value.isEmpty {
                        self.userInfo?.address = KVInfo.value
                    } else if KVInfo.key == "clientId" {
                        isHashUnique = true
                    } else if KVInfo.key == "countryCode" {
                        isHashPosition = true
                    }
                }
                
                var infoArr: [TTCNETKVInfo] = []
                
                // 上传设备表示
                if !isHashUnique {
                    let keyChain = KeychainSwift(keyPrefix: keychainKeyPrefix)
                    let key = "sdk_unique_key"
                    let unique = keyChain.get(key)
                    if let u = unique, !u.isEmpty {
                        infoArr.append(self.getUnique(uuid: u))
                    } else if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                        keyChain.set(uuid, forKey: key)
                        infoArr.append(self.getUnique(uuid: uuid))
                    }
                }
                
                // add position
                if !isHashPosition {
                    let kvInfo = TTCNETKVInfo()
                    kvInfo.key = "countryCode"
                    kvInfo.value = self.location.countryCode
                    infoArr.append(kvInfo)
                }
                
                self.updateInfo(InfoArr: infoArr)
                
                result(true, nil)
            } else {
                result(false, error)
            }
        }
    }
}

fileprivate extension TTCManager {
    func getUnique(uuid: String) -> TTCNETKVInfo {
        let kvInfo = TTCNETKVInfo()
        kvInfo.key = "clientId"
        kvInfo.value = uuid
        return kvInfo
    }
    
    func updateInfo(InfoArr: [TTCNETKVInfo]) {
        if InfoArr.isEmpty { return }
        TTCNetworkManager.updateUserInfo(InfoArr: InfoArr) { (success, error, userInfoList) -> Void in}
    }
}
