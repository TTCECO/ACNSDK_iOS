//
//  ActionManager.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/9  下午12:15.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt
import Alamofire
import web3swift
import ACN_SDK_NET

class ACNActionInfo: Object {
    
    /// actionType > 100
    @objc dynamic var actionType: Int32 = 0
    /// Transaction number
    @objc dynamic var actionHash: String = String()
    /// nonce
    @objc dynamic var nonce: Int64 = -1
    /// from user id
    @objc dynamic var fromUserID: String = String()
    /// Ancillary information
    @objc dynamic var extra: String = String()
    /// Have you uploaded the behavior to the server? 0 = no  1 = yes
    @objc dynamic var isUpload: Int = 0
    /// Have you checked? 0 = no  1 = yes, Waiting for a block  2 = yes, Block failure  3 = yes, Block success
    @objc dynamic var isCheck: Int = 0
    /// upload time
    @objc dynamic var uptime: Int64 = 0
    /// block Number when get TransactionRecipt Error
    @objc dynamic var blockNumber: Int32 = 0
    /// time
    @objc dynamic var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    /// Database primary key
    override class func primaryKey() -> String? { return "timestamp" }
    
    func hashData() -> Data {
        var hashString = "actionType=\(self.actionType)&extra=\(self.extra)&fromUserId=\(self.fromUserID)&timestamp=\(self.timestamp)".md5()
        hashString = "ufo:1:oplog:md5:\(hashString):\(ACNManager.shared.appId.description)"
        return hashString.data(using: .utf8) ?? Data()
    }
    
    func transitionProto() -> ACNNETActionInfo {
        
        let pbActionInfo = ACNNETActionInfo()
        pbActionInfo.actionType = self.actionType
        pbActionInfo.fromUserID = self.fromUserID
        pbActionInfo.actionHash = self.actionHash
        pbActionInfo.timestamp = self.timestamp
        pbActionInfo.extra = self.extra
        
        return pbActionInfo
    }
    
    /// Ignored attributes are not stored in the database
    override static func ignoredProperties() -> [String] {
        return ["description"]
    }
    
    override var description: String {
        get {
            return "actionType=\(self.actionType)\nextra=\(self.extra)\nfromUserId=\(self.fromUserID)\ntimestamp=\(self.timestamp)\nactionHash=\(self.actionHash)"
        }
    }
}

class ACNActionManager {
    
    let realmQueue = DispatchQueue(label: "realmQueue")
    let cfg: Realm.Configuration
//    var realm: Realm {
//        get {
//            return try! Realm(configuration: cfg)
//        }
//    }
    var realm: Realm? {
        get {
            do {
                return try Realm(configuration: cfg)
            } catch  {
                return nil
            }
        }
    }
    
    var timer: Timer?
    
    /// gas limit
    var gasLimit: BigUInt = BigUInt(210000)
    /// gas price
    var gasPrice: BigUInt = BigUInt("500000000000") // 500 gwei
    
    /// nonce
    var nonce: BigInt = BigInt(-1)
    
    /// Maximum upload behavior
    let uploadCountLimit = 1
    /// is uploading behavior?
    var isUploadAction: Bool = false
    /// is transaction?
    var isTransaction: Bool = false
    /// is checking transaction?, Ensure this is changed in main queue
    var isChecking: Bool = false
    /// balance is enough
    var isBalance: Bool = true
    /// error count for 'requestPrivateKeyAndAddress'
    var transactionErrorCount: Int {
        didSet {
            if transactionErrorCount > 5 {
                transactionErrorCount = 0
                ACNManager.shared.requestPrivateKeyAndAddress { (_, _) -> Void in }
            }
        }
    }
    
    /// creat queue of checking transaction
    let checkQueue: DispatchQueue = DispatchQueue(label: "com.ttc.eco.checkQueue")

    private var _actionRPCManager: ACNActionRPCManager?
    var actionRPCManager: ACNActionRPCManager? {
        
        if let curl = _actionRPCManager?.web.provider.url,
           curl.absoluteString == acnServer.actionURL {
            
            return _actionRPCManager
        }
        
        guard let url = URL(string: acnServer.actionURL),
              let pkStr = ACNManager.shared.privateKey else {
            return nil
        }
        
        let pkData = Data(hex: pkStr)
        _actionRPCManager = ACNActionRPCManager(url: url, privateKey: pkData)
        return _actionRPCManager
    }
    
    var timeInterval: TimeInterval = 15
    
    static let shared = ACNActionManager()
    /// 需要更新版本号
    init() {
        
        var realmPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        realmPath += "/action.realm"
        var bid = Bundle.main.bundleIdentifier ?? ""
        bid = bid.md5()
        var ACN = "ttc-" + bid
        ACN = ACN.md5()
        var key = ACN + bid
        let i = key.index(key.startIndex, offsetBy: 64)
        key = String(key.prefix(upTo: i))
        let data = key.data(using: .utf8) ?? Data()
        cfg = Realm.Configuration.init(fileURL: URL(string: realmPath), encryptionKey: data, readOnly: false, schemaVersion: 5, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 5 {
                
            }
        }, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: [ACNActionInfo.self])
        
        transactionErrorCount = 0
    }
    
    func runScheduledTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(checkAndupload), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    
    func setDefaultManager() {
        
        self.gasLimit = BigUInt(210000)
        self.gasPrice = BigUInt("5000000000") // 500 gwei
        self.nonce = BigInt(-1)
        
        self.transactionErrorCount = 0
        
        self.timer?.invalidate()
        self.timer = nil
        self.timeInterval = 20
        runScheduledTimer()
        
    }
    
    /// Behavior write to database
    func insertAction(actionInfo: ACNActionInfo) {
        realmQueue.async {
            //            ACNPrint(actionInfo)
            if let realm = self.realm {
                try? realm.write {
                    realm.add(actionInfo, update: .modified)
                }
            }
            
            self.actionWriteBlockChain(actionInfo: actionInfo)
        }
        
        self.queriesActionAndUpload()
    }
    
    /// remove behavior from database
    func deleteAction() {
        
        realmQueue.async {
            
            guard let userinfo = ACNManager.shared.userInfo else { return }
            
            if let realm = self.realm {
                let actionInfos = realm.objects(ACNActionInfo.self).filter("fromUserID = '\(userinfo.userId)' AND actionHash != '' AND isUpload = 1 AND isCheck = 3")
                try? realm.write {
                    realm.delete(actionInfos)
                }
            }
        }
    }
    
    /// query and upload
    func queriesActionAndUpload() {
        realmQueue.async {
            if self.isUploadAction { return }
            guard let userinfo = ACNManager.shared.userInfo else { return }
            if let realm = self.realm {
                let results = realm.objects(ACNActionInfo.self).filter("fromUserID = '\(userinfo.userId)' AND isUpload = 0")
                if results.count >= self.uploadCountLimit {
                    self.isUploadAction = true
                    
                    var ecoActions: [ACNNETActionInfo] = []
                    for action in results {
                        ecoActions.append(action.transitionProto())
                    }
                    
                    ACNPrint("start upload behavior....")
                    self.uploadAction(ecoActions: ecoActions)
                }
            }
        }
    }
    
    /// Update upload status to uploaded
    func updateAction(actionInfos: [ACNNETActionInfo]) {
        realmQueue.async {
            if let realm = self.realm {
                for action in actionInfos {
                    guard let act = realm.objects(ACNActionInfo.self).filter("timestamp = \(action.timestamp)").first else { return }
                    try? realm.write {
                        act.isUpload = 1
                    }
                }
            }
            self.isUploadAction = false
        }
    }
    
    /// query and transaction
    func queriesActionAndTransaction() {
        realmQueue.async {
            if self.isTransaction { return }
            guard let userinfo = ACNManager.shared.userInfo else { return }
            if let realm = self.realm {
                if let actionInfo = realm.objects(ACNActionInfo.self).filter("fromUserID = '\(userinfo.userId)' AND actionHash = '' AND nonce != 0").first {
                    self.actionWriteBlockChain(actionInfo: actionInfo)
                } else {
                    guard let actionInfo = realm.objects(ACNActionInfo.self).filter("fromUserID = '\(userinfo.userId)' AND actionHash = ''").first else { return }
                    self.actionWriteBlockChain(actionInfo: actionInfo)
                }
            }
        }
    }
    
    /// upload block chain
    func actionWriteBlockChain(actionInfo: ACNActionInfo) {
        
        if self.isTransaction {
            ACNPrint("Trading. . .")
            return
        }
        
        /// fetch nonce
        if self.nonce == BigInt(-1) {
            getTransactionCount()
            return
        }
        
        if !self.isBalance {
            self.isEnoughBalance()
            return
        }
        
        /// start transaction
        self.isTransaction = true
        
        var nonce: BigUInt
        let data: Data
        let timestamp: Int64
        let gasLimit: BigUInt
        let gasPrice: BigUInt
        
        nonce = BigUInt(self.nonce)
        if actionInfo.nonce != 0, actionInfo.nonce != -1 {
            nonce = BigUInt(actionInfo.nonce)
        }
        
        data = actionInfo.hashData()
        timestamp = actionInfo.timestamp
        gasLimit = self.gasLimit
        gasPrice = self.gasPrice
        
        if actionInfo.fromUserID != ACNManager.shared.userInfo?.userId {
            self.isTransaction = false
            return
        }
        
        guard let userinfo = ACNManager.shared.userInfo else {
            self.isTransaction = false
            return
        }
        
        guard let from = EthereumAddress(ACNManager.shared.actionAddress?.to0x ?? ""),
            let to = EthereumAddress(userinfo.address?.to0x ?? "") else {
            
            self.isTransaction = false
            return
        }
        
        actionRPCManager?.sendTransaction(from: from,
                                          to: to,
                                          gasLimit: gasLimit,
                                          gasPrice: gasPrice,
                                          value: BigUInt(0),
                                          nonce: nonce,
                                          data: data) { resultValue in
            
            switch resultValue {
            case .success(let hex):
                ACNPrint("Transaction success -> hash: \(hex)")
                self.realmQueue.async {
                    
                    /// update database
                    if let realm = self.realm {
                        let action = realm.objects(ACNActionInfo.self).filter("timestamp = \(timestamp)").first
                        try? realm.write {
                            action?.actionHash = hex
                            action?.nonce = Int64(nonce.description) ?? 0
                            //                        action?.isUpload = 0 // 有可能被上传服务器后设为1了
                            action?.uptime = Int64(Date().timeIntervalSince1970*1000)
                        }
                    }
                    
                }
                
                self.nonce += 1
                ACNPrint("current nonce: \(self.nonce)")
                self.isTransaction = false
                /// Inquire whether there is no transaction, initiate a transaction
                self.queriesActionAndTransaction()
            //                self.queriesActionAndUpload()
            case .failure(let error):
                
                ACNPrint("Transaction failed: \(error)")
                /// end transation
                self.isTransaction = false
                self.transactionErrorCount += 1
                
                self.isEnoughBalance()
                self.doError(error: error)
            }
        }
    }
    
    /// Upload user behavior to the server
    func uploadAction(ecoActions: [ACNNETActionInfo]) {
        
        ACNPrint("behavior count :\(ecoActions.count)")
        
        if ecoActions.first?.fromUserID != ACNManager.shared.userInfo?.userId {
            self.isUploadAction = false
            return
        }
        
        ACNNetworkManager.uploadAction(actionInfoList: ecoActions) { error in
            if error != nil {
                self.isUploadAction = false
                ACNPrint("Upload behavior failed: \(String(describing: error?.errorDescription))")
            } else {
                ACNPrint("Upload behavior succeeded")
                self.updateAction(actionInfos: ecoActions)
                self.queriesActionAndUpload()
            }
        }
    }
    
    // query transaction count
    func getTransactionCount() {
        
        guard let address = ACNManager.shared.actionAddress, !address.isEmpty else {
            return
        }
        
        let userid = ACNManager.shared.userInfo?.userId
        self.actionRPCManager?.getTransactionPendingCount(address: address) { (result) in
            switch result {
            case .success(let nonce):
                ACNPrint("fetch nonce success, nonce: \(nonce.description)")
                
                if self.nonce == BigInt(-1) || nonce > self.nonce {
                    self.nonce = nonce
                }
                
                if userid != ACNManager.shared.userInfo?.userId {
                    self.nonce = BigInt(-1)
                }
                
                ACNPrint("Used nonce: \(self.nonce.description)")
                
                self.queriesActionAndTransaction()
                self.deleteAction()
                
            case .failure(let error):
                ACNPrint("Get nonce failed: \(error)")
            }
        }
    }
    
    func afterCheck(_ afterTime: Int = 2) {
        
        let time = DispatchTime.now() + DispatchTimeInterval.seconds(afterTime)
        
        self.checkQueue.asyncAfter(deadline: time) {
            ACNPrint("will start checking >>>>>>>>> ")
            self.checkTransaction()
        }
    }
    
    // check transaction and upload action
    @objc func checkAndupload() {
        afterCheck()
        
        DispatchQueue.global().async {
            
            self.getTransactionCount()
        }
    }
    
    // check transaction
    func checkTransaction() {
        
        if !ACNManager.shared.SDKEnabled { return }
        if !ACNManager.shared.isRegister { return }
        guard let userinfo = ACNManager.shared.userInfo else { return }
        if isChecking { return }
        
        let userid = ACNManager.shared.userInfo?.userId
        if let actionInfo = self.realm?.objects(ACNActionInfo.self).filter("fromUserID = '\(userinfo.userId)' AND actionHash != '' AND isCheck < 3").sorted(byKeyPath: "nonce").first {
            
            if userid != userinfo.userId { return }
            isChecking = true
            
            let timestamp = actionInfo.timestamp
            let hash = actionInfo.actionHash
//            let uptime = actionInfo.uptime
            let transactionNonce = actionInfo.nonce
            let lastBlockNumber = actionInfo.blockNumber
            
            ACNPrint("In checking, getTransactionReceipt, time: \(Date().timeIntervalSince1970.description)")
            
            self.actionRPCManager?.getTransactionReceipt(txhash: hash) { (result) in
                switch result {
                case .success(let recepit):
                    
                    if recepit.status == .ok {
                        self.realmQueue.async {
                            if let tmpRealm = self.realm {
                                if let info = tmpRealm.objects(ACNActionInfo.self).filter("timestamp = \(timestamp)").first {
                                    try? tmpRealm.write {
                                        info.isCheck = 3 // Check successful
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.isChecking = false
                                
                                /// Continue to check
                                self.afterCheck()
                            }
                        }
                        
                        ACNPrint("Transaction success:\n hash: \(hash) \n blockNumber = \(recepit.blockNumber) \n nonce = \(transactionNonce)")
                    } else {
                        ACNPrint("status false, reset ------- \(hash)")
                        self.resetHash(timestamp)
                    }
                    
                case .failure(_):
                    self.gerReciptError(timestamp, lastBlockNumber: lastBlockNumber, hash: hash)
                }
            }
        } else {
            ACNPrint("all is checked")
        }
    }
    
    /// 上传出错，重置
    func resetHash(_ timestamp: Int64) {
        
        guard let address = ACNManager.shared.actionAddress, !address.isEmpty else {
            return
        }
        
        self.actionRPCManager?.getTransactionCount(address: address) { (result) in
            switch result {
            case .success(let nonce):
                ACNPrint("fetch nonce success, nonce: \(nonce.description)")
                self.resetHahsWithNonce(timestamp, nonce: Int64(nonce))
            case .failure(let error):
                ACNPrint("Get nonce failed: \(error)")
                self.resetHahsWithNonce(timestamp, nonce: 0)
            }
        }
        
    }
    
    func resetHahsWithNonce(_ timestamp: Int64, nonce: Int64) {
        
        self.realmQueue.async {
            if let tmpRealm = self.realm {
                if let info = tmpRealm.objects(ACNActionInfo.self).filter("timestamp = \(timestamp)").first {
                    try? tmpRealm.write {
                        info.actionHash = ""  // Hash restore
                        info.isCheck = 2      // Block failure
                        info.nonce = nonce
    //                    info.isUpload = 0     // may be 1
                        info.blockNumber = 0   // reset block number
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isChecking = false
                /// Continue to check
                self.afterCheck()
                /// reset nonce
                self.nonce = BigInt(-1)
                /// re-upload
                self.getTransactionCount()
            }
        }
    }
    
    /// MARK: - json rpc error
    func dealwithRPCError(error: ACNRPCError) {
        switch error {
        case .RPCSuccessError(_, let message):
            // nonce, Have problems re-query "replacement transaction underpriced"？？？
            if message == "nonce too low" {
                self.getTransactionCount()
            }
        default:
            break
        }
    }
    
    /// return SessionTaskError and jsonrpc
    func doError(error: Error) {
        guard let RPCError: ACNRPCError = error as? ACNRPCError else {
            return
        }
        
        self.dealwithRPCError(error: RPCError)
    }
    
    func isEnoughBalance() {
        
        if let address = ACNManager.shared.actionAddress, !address.isEmpty {
            self.actionRPCManager?.getSideBalance(for: address, completion: { (result) in
                switch result {
                case .success(let balance):
                    let gas = self.gasLimit*self.gasPrice
                    if balance < gas {
                        self.isBalance = false
                    } else {
                        self.isBalance = true
                    }
                case .failure(_):
                    break
                }
            })
        }
    }
 
    func gerReciptError(_ timestamp: Int64, lastBlockNumber: Int32, hash: String) {
        
        self.actionRPCManager?.getBlockNumber() { result in
            switch result {
            case .success(let number):
                
                ACNPrint("get block number: \(number)")
                
                let blockNumber = Int32(number)
                if lastBlockNumber == 0 {
                    
                    ACNPrint("save block number")
                    
                    self.realmQueue.async {
                        if let tmpRealm = self.realm {
                            if let info = tmpRealm.objects(ACNActionInfo.self).filter("timestamp = \(timestamp)").first {
                                try? tmpRealm.write {
                                    info.isCheck = 3 // Check successful
                                    info.blockNumber = blockNumber
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.isChecking = false
                            /// Continue to check
                            self.afterCheck(10)
                        }
                    }
                } else if blockNumber > lastBlockNumber + 1000 {
                    ACNPrint("block number is too big, reset transaction ------- \(hash)")
                    self.resetHash(timestamp)
                } else {
                    ACNPrint("block is normal")
                    DispatchQueue.main.async {
                        self.isChecking = false
                        /// Continue to check
                        self.afterCheck(10)
                    }
                }
            case .failure(let error):
                ACNPrint("get block number error: \(error)")
                DispatchQueue.main.async {
                    self.isChecking = false
                    
                    /// Continue to check
                    self.afterCheck()
                }
            }
        }
    }
}
