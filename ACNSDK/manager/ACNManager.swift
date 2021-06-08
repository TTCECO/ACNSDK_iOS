//
//  ACNManager.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/2  下午4:22.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import BigInt
import ACN_SDK_NET
import TTCPay
import web3swift
import CryptoSwift

internal class ACNManager {

    static let shared = ACNManager()
    /// Dapp Private key
    var privateKey: String?
    /// current Private key·s address
    var currentAddress: String?
    /// Dapp address
    var actionAddress: String?
    var isRequestPrivatekey: Bool = false

    // MARK: - register -
    var appId: String!
    var secretKey: String!
    var isRegister: Bool = false

    // MARK: - user -
    var userInfo: ACNUserInfo?
    var isLogin: Bool = false

    // MARK: - bind -
    let DAPP = ["com.tataufo.TTC-SDK-iOS-Demo"]
    var walletAddress: String?
    var walletScheme: String?
    var walletLanguage: String = "en"
    var reward: Int = 0
    var bindStartTime: TimeInterval = 0
    var bindBackBlock: ((Bool, ACNSDKError?, _ address: String?) -> Void)?
    /// 跳转的绑定钱包类型
    var walletBindType: Int32 = 1
    
    /// 1 - development 2 - production
    var environment: Int32 = 1

    /// SDK is available
    var SDKEnabled: Bool = true {
        didSet {
            if !SDKEnabled {
                ACNActionManager.shared.timer?.invalidate()
            } else {
                if ACNManager.shared.isLogin {
                    ACNActionManager.shared.timer?.invalidate()
                    ACNActionManager.shared.timer = nil
                    ACNActionManager.shared.runScheduledTimer()
                }
            }
        }
    }
    /// SDK is log
    var logEnable: Bool = false
    // location
    let location = ACNLocationManager()
    
    /// Register to start the SDK
    func register(appId: String, secretKey: String) {

        self.appId = appId
        self.secretKey = secretKey
        ACNPrint("===========================start===========================")
        ACNPrint("Startup completed appId: \(appId),secretKey: \(secretKey)")
        ACNPrint("ACNSDK version: \(SDKVersion)")
        
        ACNNetManager.shared.appId = appId
        ACNNetManager.shared.secretKey = secretKey
        ACNNetManager.shared.SDKVersion = SDKVersion
        ACNNetManager.shared.apiURL = acnServer.apiURL
        
        TTCPay.shared.appId = appId
        TTCPay.shared.secretKey = secretKey
        TTCPay.shared.apiURL = acnServer.apiURL
        
        // get chainID
//        ACNActionManager.shared.getChainID()
        // Open positioning
        location.locate()
    }
}

// MARK: - user -
extension ACNManager {

    func setDefault() {
        
        userInfo = nil
        privateKey = nil
        actionAddress = nil
        isRequestPrivatekey = false
        
        isRegister = false
        isLogin = false
        
        ACNActionManager.shared.timer?.invalidate()
    }
    
    func login(userInfo: ACNUserInfo, result: @escaping (Bool, ACNSDKError?, ACNUserInfo?) -> Void) {
        
        setDefault()
        
        self.userInfo = userInfo
        
        ACNNetManager.shared.userID = userInfo.userId
        
        ACNActionManager.shared.timer?.invalidate()
        requestRegisterUser(result: { (success, error) -> Void in
            
            self.isLogin = success
            
            if success {
                
                ACNPrint("login successful userId: \(String(describing: self.userInfo?.userId))")
                result(true, nil, self.userInfo)
                
                ACNActionManager.shared.setDefaultManager()
                self.requestPrivateKeyAndAddressRetry()
                
            } else {
                
                result(false, ACNSDKError(error: error), nil)
                ACNPrint("Login failed: \(String(describing: error?.errorDescription))")
            }
        })
        
        fetchWalletType()
    }

    func logout() {

        ACNPrint("sign out")
        /// user logout
        setDefault()
    }

    func update(userInfo: ACNUserInfo, result: @escaping (Bool, ACNSDKError?, ACNUserInfo?) -> Void) {
        
        let userid = ACNManager.shared.userInfo?.userId

        var kvInfoArr: [ACNNETKVInfo] = []
        
        let kvInfo = ACNNETKVInfo()
        kvInfo.key = "userId"
        kvInfo.value = userInfo.userId
        kvInfoArr.append(kvInfo)
        
        if let nickname = userInfo.nickname {
            let kvInfo = ACNNETKVInfo()
            kvInfo.key = "nickname"
            kvInfo.value = nickname
            kvInfoArr.append(kvInfo)
        }
        if let avatarUrl = userInfo.avatarUrl {
            let kvInfo = ACNNETKVInfo()
            kvInfo.key = "avatarUrl"
            kvInfo.value = avatarUrl
            kvInfoArr.append(kvInfo)
        }
        if let gender = userInfo.gender {
            let kvInfo = ACNNETKVInfo()
            kvInfo.key = "gender"
            kvInfo.value = gender
            kvInfoArr.append(kvInfo)
        }
        if let telephone = userInfo.telephone {
            let kvInfo = ACNNETKVInfo()
            kvInfo.key = "telephone"
            kvInfo.value = telephone
            kvInfoArr.append(kvInfo)
        }
        
        if let email = userInfo.email {
            let kvInfo = ACNNETKVInfo()
            kvInfo.key = "email"
            kvInfo.value = email
            kvInfoArr.append(kvInfo)
        }
        
        /// Update info
        ACNNetworkManager.updateUserInfo(InfoArr: kvInfoArr) { (success, error, userInfoList) -> Void in

            if success {
                
                if userid != ACNManager.shared.userInfo?.userId {
                    result(false, ACNSDKError(type: .UserChanged), nil)
                    return
                }
                
                self.userInfo = userInfo
                
                guard let list = userInfoList else {
                    ACNPrint("Update user information successfully, but return data is null")
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
                ACNPrint("Update user information successfully")
                result(true, nil, self.userInfo)
            } else {
                ACNPrint("Update user information faile: \(String(describing: error?.errorDescription))")
                result(false, ACNSDKError(error: error), nil)
            }
        }
    }
    
    /// query account balance
    func queryAccountBalance(resulted: @escaping (Bool, ACNSDKError?, String) -> Void) {
        
        ACNRPCManager.getEthBalance(for: self.userInfo?.address ?? "") { (result) in
            switch result {
            case .success(let balance):
                ACNPrint("query account balance successfully, balance: \(balance.amountFull)")
                resulted(true, nil, balance.amountFull)
            case .failure(let error):
                ACNPrint("query account balance faile: \(error)")
                resulted(false, ACNSDKError(description: String(describing: error)), "0")
            }
        }
    }
    
    /// query wallet TTC balance
    func queryWalletBalance(resulted: @escaping (Bool, ACNSDKError?, String) -> Void) {
        
        ACNRPCManager.getEthBalance(for: self.userInfo?.wallet ?? "") { (result) in
            switch result {
            case .success(let balance):
                ACNPrint("query wallet balance successfully, balance: \(balance.amountFull)")
                resulted(true, nil, balance.amountFull)
            case .failure(let error):
                ACNPrint("query wallet balance faile: \(error)")
                resulted(false, ACNSDKError(description: String(describing: error)), "0")
            }
        }
    }
    
    /// query wallet ACN balance
    func queryWalletACNBalance(resulted: @escaping (Bool, ACNSDKError?, String) -> Void) {
        
        ACNTokenManager.shared.banlance(self.userInfo?.wallet ?? "") { (result) in
            switch result {
            case .success(let b):
                let balance = Balance(value: BigInt(b))
                ACNPrint("query wallet balance successfully, balance: \(balance.amountFull)")
                resulted(true, nil, balance.amountFull)
            case .failure(let error):
                ACNPrint("query wallet balance faile: \(error)")
                resulted(false, ACNSDKError(description: String(describing: error)), "0")
            }
        }
        
    }
    
    /// handle user action
    func handleUserActionInfo(actionType: Int32, extra: String) {
        
        let actionInfo = ACNActionInfo()
        actionInfo.actionType = actionType
        actionInfo.fromUserID = self.userInfo?.userId ?? ""
        actionInfo.extra = extra
        
        ACNActionManager.shared.insertAction(actionInfo: actionInfo)
        
        if !self.isRegister || self.privateKey == nil {
            requestPrivateKeyAndAddressRetry()
        }
    }
    
    func fetchWalletType() {
        ACNNetworkManager.fetchScheme { (type, error) in
            self.walletBindType = type
        }
    }
}

// MARK: - bind -
extension ACNManager {
    
    /// Wallet binding
    func handleWalletBind(params: [String: String]) {

        let scheme = params["wltScheme"]
        
        if scheme == "ACNWallet" {
            self.walletAddress = params["address"]
            self.walletScheme = params["wltScheme"]
            self.walletLanguage = params["language"] ?? "en"
            self.reward = Int(params["reward"] ?? "0") ?? 0
            
            if self.isLogin {
                ACNPrint("bind - go to binding page")
                let bindVC = ACNBindViewController(language: self.walletLanguage)
                bindVC.modalPresentationStyle = .fullScreen
                ACNWindow.shared.rootViewController?.present(bindVC, animated: true, completion: nil)
            } else {
                ACNPrint("bind - User not login")
            }
        } else if scheme == "ACNBindBack" {
            
            if let bindBlock = self.bindBackBlock {
                
                let date = Date().timeIntervalSince1970
                if (date - self.bindStartTime) < 180 {
                    
                    if let success = params["success"], success == "true" {
                        self.userInfo?.wallet = params["address"]
                        bindBlock(true, nil, params["address"])
                    } else {
                        bindBlock(false, ACNSDKError(description: "bind failure"), nil)
                    }
                }
                
                self.bindStartTime = 0
                self.bindBackBlock = nil
            }
        }
    }

    /// back wallet -1 cancel， 0 faile，1 success，
    func backWallet(bindState: Int, reward: Int32, symbol: String) {
        
        var scheme: String
        if self.walletBindType == 1 {
            scheme = "FTACNWallet"
            if self.environment == 2 {
                scheme = "ACNWallet"
            }
        } else {
            scheme = "FTWallet"
            if self.environment == 2 {
                scheme = "TTCWallet"
            }
        }
        
        let walletUrlStr = scheme + "://Bind?bundleID=\(Bundle.main.bundleIdentifier ?? "")&bindState=\(bindState)&reward=\(ACNManager.shared.reward)&symbol=\(symbol)"
        let walletUrl = URL(string: walletUrlStr)

        guard let wltUrl = walletUrl else { return }

        if !UIApplication.shared.openURL(wltUrl) {
            ACNPrint("bind - Return failure")
        }
    }

    func unBindWallet(usetId: String, result: @escaping (Bool, ACNSDKError?) -> Void) {

        let userid = ACNManager.shared.userInfo?.userId
        
        ACNNetworkManager.bindingDapp(isBind: false, walletAddress: self.userInfo?.wallet ?? "") { (success, error, info) -> Void in

            if success {
                
                if userid != ACNManager.shared.userInfo?.userId {
                    result(false, ACNSDKError(type: .UserChanged))
                    return
                }
                
                self.userInfo?.wallet = nil
                ACNPrint("Unbind wallet successfully")
                result(true, nil)
            } else {
                ACNPrint("Unbind wallet failed: \(String(describing: error?.errorDescription))")
                result(false, ACNSDKError(error: error))
            }
        }
    }
    
    // sdk绑定钱包
    func bindWallet(iconUrl: String, result: @escaping (Bool, ACNSDKError?, _ address: String?) -> Void) {
        
        var appName = ""
        let info = Bundle.main.infoDictionary
        if info != nil, ((info!["CFBundleDisplayName"] as? String) != nil) {
            appName = info!["CFBundleDisplayName"] as! String
        }
        
        var scheme: String
        if self.walletBindType == 1 {
            scheme = "FTACNWallet"
            if self.environment == 2 {
                scheme = "ACNWallet"
            }
        } else {
            scheme = "FTWallet"
            if self.environment == 2 {
                scheme = "TTCWallet"
            }
        }
        
        var iconString = ""
        if let iconData = iconUrl.data(using: .utf8) {
            iconString = iconData.base64EncodedString()
        }
        
        let walletUrlStr = scheme + "://BindWallet?bundleID=\(Bundle.main.bundleIdentifier ?? "")&appID=\(self.appId.description)&userID=\(self.userInfo?.userId ?? "")&icon=\(iconString)&name=\(appName)"
        let walletUrl = URL(string: walletUrlStr)
        
        guard let wltUrl = walletUrl else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(wltUrl, options: [:]) { (success) in
                if success {
                    self.bindBackBlock = result
                    self.bindStartTime = Date().timeIntervalSince1970
                } else {
                    ACNPrint("bind - Return failure")
                    result(false, ACNSDKError(description: "not open app"), nil)
                    
                    let url: String
                    if self.walletBindType == 1 {
                        url = "https://acn.eco/acornbox/download?appID=\(self.appId.description)"
                    } else {
                        url = "https://wallet.ttc.eco/download?appID=\(self.appId.description)"
                    }
                    
                    guard let downloadURL = URL(string: url) else { return }
                    UIApplication.shared.open(downloadURL, options: [:]) { (_) in
                    }
                }
            }
        } else {
            if !UIApplication.shared.openURL(wltUrl) {
                ACNPrint("bind - Return failure")
                result(false, ACNSDKError(description: "not open app"), nil)
                let url: String
                if self.walletBindType == 1 {
                    url = "https://acn.eco/acornbox/download?appID=\(self.appId.description)"
                } else {
                    url = "https://wallet.ttc.eco/download?appID=\(self.appId.description)"
                }
                guard let downloadURL = URL(string: url) else { return }
                UIApplication.shared.openURL(downloadURL)
            } else {
                self.bindBackBlock = result
                self.bindStartTime = Date().timeIntervalSince1970
            }
        }
    }
}

// MARK: - net -
extension ACNManager {
    
    /// Request private key to automatically re-request if it fails. Up to five times
    /// get privateKey,address,gas price,gas limit,
    func requestPrivateKeyAndAddressRetry() {

        if !self.isLogin {
            return
        }

        requestPrivateKeyAndAddress { (success, error) -> Void in
            
            self.isRegister = success
            if success {
                ACNActionManager.shared.isEnoughBalance()
                ACNActionManager.shared.getChainID()
                ACNActionManager.shared.getTransactionCount()
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

    func requestPrivateKeyAndAddress(result: @escaping (Bool, ACNInternalError?) -> Void) {

        if self.isRequestPrivatekey {
            result(false, .requesting)
            return
        }
        
        let userid = ACNManager.shared.userInfo?.userId
        self.isRequestPrivatekey = true
        
        /// Get the private key used by Dapp uploading behavior, decrypt with Dapp's secretKey
        ACNNetworkManager.getBaseInfo { (success, error, dataMessage) -> Void in
            self.isRequestPrivatekey = false
            
            if success {
                
                guard let data = dataMessage else {
                    result(false, .responseDataParseError)
                    return
                }
                
                contracts = data.contracts
                
                if !data.sideChainRpcurl.isEmpty, !data.mainChainRpcurl.isEmpty {
                    acnServer = ACNServer(apiURL: acnServer.apiURL, actionURL: data.sideChainRpcurl, ACNURL: data.mainChainRpcurl)
                }
                
                if !data.uploadOperationLogGasPrice.isEmpty, data.uploadOperationLogGasLimit != 0 {
                    ACNActionManager.shared.gasPrice = BigInt(data.uploadOperationLogGasPrice) ?? BigInt("500000000000")
                    ACNActionManager.shared.gasLimit = BigInt(data.uploadOperationLogGasLimit)
                }

                guard let encodePrivateKey = dataMessage?.encodePrivateKey, let dappActionAddress = dataMessage?.dappActionAddress else {
                    ACNPrint("Private key is empty")
                    result(false, .responseDataParseError)
                    return
                }
                
                guard let baseData = Data(base64Encoded: encodePrivateKey, options: []), baseData.count > 16 else {
                    ACNPrint("Private key failed to data")
                    result(false, .responseDataParseError)
                    return
                }

                let bytes: [UInt8] = Array(baseData)
                let iv: [UInt8] = Array(bytes.prefix(16))
                let crypted: [UInt8] = Array(bytes.suffix(bytes.count - 16))
                let secretKey: [UInt8] = Array(self.secretKey.utf8)

                do {
                    var decrypted = try CryptoSwift.AES(key: secretKey, blockMode: CBC(iv: iv), padding: .zeroPadding).decrypt(crypted)
                    if let padding = decrypted.last {
                        let length = decrypted.count - Int(padding)
                        decrypted = Array(decrypted.prefix(length))
                    }

                    let keyData = Data(bytes: decrypted)
                    guard let privateKey = String(data: keyData, encoding: .utf8) else {
                        ACNPrint("Private key failed to string")
                        result(false, .responseDataParseError)
                        return
                    }
                    
                    if userid != ACNManager.shared.userInfo?.userId {
                        result(false, .responseDataParseError)
                        return
                    }
                    
                    if privateKey.count == 64 {
                        self.privateKey = privateKey
                    }
                    
                    self.actionAddress = dappActionAddress
                    ACNPrint("Request private key success, actionAddress: \(dappActionAddress)")
                    result(true, nil)
                } catch {
                    ACNPrint("Failed to decrypt the private key: \(error)")
                    result(false, .responseDataParseError)
                }

            } else {
                ACNPrint("Failed to get the private key: \(String(describing: error))")
                guard let err = error else {
                    result(false, .responseDataParseError)
                    return
                }
                result(false, err)
            }
        }
    }

    func requestRegisterUser(result: @escaping (Bool, ACNInternalError?) -> Void) {

        ACNNetworkManager.registerUser { (success, error, dataMessage) -> Void in

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
                
                var infoArr: [ACNNETKVInfo] = []
                
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
                    let kvInfo = ACNNETKVInfo()
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

fileprivate extension ACNManager {
    func getUnique(uuid: String) -> ACNNETKVInfo {
        let kvInfo = ACNNETKVInfo()
        kvInfo.key = "clientId"
        kvInfo.value = uuid
        return kvInfo
    }
    
    func updateInfo(InfoArr: [ACNNETKVInfo]) {
        if InfoArr.isEmpty { return }
        ACNNetworkManager.updateUserInfo(InfoArr: InfoArr) { (success, error, userInfoList) -> Void in}
    }
}
