//
//  ACNNetworkTransaction.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/6  下午12:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import JSONRPCKit
import BigInt
import TrustCore
import ACN_SDK_NET
import Alamofire

enum RPCErrorType: Int32 {
    case null = 133
    case NotDic = 132
    case NotGetError = 131
    case NotInt = 130
}

class ACNRPCManager: NSObject {
    
    // 解析error
    static func isRespondError(result: Result<Any>) -> Result<Any> {
        switch result {
        case .success(let resultValue):
            
            if resultValue is NSNull {
                return Result.failure(ACNRPCError.RPCSuccessError(RPCErrorType.null.rawValue, "null"))
            }
            
            guard let value = resultValue as? [String: Any] else {
                return Result.failure(ACNRPCError.RPCSuccessError(RPCErrorType.NotDic.rawValue, "Can't as [String: Any]"))
            }
            
            if let e = value["error"] {
                if let error = e as? [String: Any] {
                    let message = error["message"] as! String
                    let code: Int32 = error["code"] as! Int32
                    return Result.failure(ACNRPCError.RPCSuccessError(code, message))
                } else {
                    return Result.failure(ACNRPCError.RPCSuccessError(RPCErrorType.NotGetError.rawValue, "Failed to get error"))
                }
            } else {
                
                if value["result"] is NSNull {
                    return Result.failure(ACNRPCError.RPCSuccessError(RPCErrorType.null.rawValue, "null"))
                }
            
                return Result.success(value)
            }
            
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    // MARK: - RPC request
    static func getEthBalance(for address: String, completion: @escaping (Result<Balance>) -> Void) {
        ACNServiceRequest(batch: BatchFactory().create(BalanceRequest(address: address.to0x)), url: acnServer.ACNURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                let balance = Balance(value: BigInt(result.drop0x, radix: 16) ?? BigInt(0))
                completion(Result.success(balance))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    static func getSideBalance(for address: String, completion: @escaping (Result<Balance>) -> Void) {
        ACNServiceRequest(batch: BatchFactory().create(BalanceRequest(address: address.to0x)), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                let balance = Balance(value: BigInt(result.drop0x, radix: 16) ?? BigInt(0))
                completion(Result.success(balance))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    /// fetch latest Nonce
    static func getTransactionCount(address: String, completion: @escaping (Result<BigInt>) -> Void) {
        
        ACNServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: address.to0x, state: "latest")), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                let nonce = BigInt(result.drop0x, radix: 16) ?? BigInt()
                completion(Result.success(nonce))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    /// fetch pending Nonce
    static func getTransactionPendingCount(address: String, completion: @escaping (Result<BigInt>) -> Void) {
        
        ACNServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: address.to0x, state: "pending")), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                let nonce = BigInt(result.drop0x, radix: 16) ?? BigInt()
                completion(Result.success(nonce))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    /// fetch version
    static func fetchVersion(completion: @escaping (Result<String>) -> Void) {
        
        ACNServiceRequest(batch: BatchFactory().create(VersionRequest()), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                completion(Result.success(result))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    static func sendTransaction(transaction: Transaction, completion: @escaping (Result<String>) -> Void) {
        ACNRPCManager.signAndSend(transaction: transaction, completion: completion)
    }
    
    static private func signAndSend(transaction: Transaction, completion: @escaping (Result<String>) -> Void) {
        let data = signTransaction(transaction)
        
        guard let signData = data else {
            completion(Result.failure(ACNRPCError.failedToSignTransaction))
            return
        }
        
        ACNRPCManager.approve(transaction: transaction, data: signData, completion: completion)
    }
    
    static private func signTransaction(_ transaction: Transaction) -> Data? {
        let signer: Signer = EIP155Signer(chainId: BigInt(transaction.chainID))
        
        let tmptrans = Transaction.init(from: transaction.from.to0x, to: transaction.to.to0x, gasLimit: transaction.gasLimit, gasPrice: transaction.gasPrice, value: transaction.value, nonce: transaction.nonce, data: transaction.data, chainID: transaction.chainID)
        
        let hash = signer.hash(transaction: tmptrans)
        
        guard let pk = ACNManager.shared.privateKey?.to0x, let keyData = Data(hexString: pk), keyData.count > 0 else {
            return nil
        }
        
        let signature = EthereumCrypto.sign(hash: hash, privateKey: keyData)
        let (r, s, v) = signer.values(transaction: tmptrans, signature: signature)
        let data = RLP.encode([
            tmptrans.nonce,
            tmptrans.gasPrice,
            tmptrans.gasLimit,
            Data(hexString: tmptrans.to) ?? Data(),
            tmptrans.value,
            tmptrans.data,
            v, r, s
            ])
        return data
    }
    
    static private func approve(transaction: Transaction, data: Data, completion: @escaping (Result<String>) -> Void) {
        let dataHex = data.hexEncoded
        ACNServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: dataHex)), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                completion(Result.success(result))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    static func getTransaction(hash: String, completion: @escaping (Result<[String: Any]>) -> Void) {
        
        ACNServiceRequest(batch: BatchFactory().create(GetTransactionRequest(hash: hash.to0x)), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                let value = responseValue as! [String: Any]
                let result = value["result"] as! [String: Any]
                completion(Result.success(result))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    static func getTransactionReceipt(hash: String, completion: @escaping (Result<TransactionReceipt>) -> Void) {
        
        ACNServiceRequest(batch: BatchFactory().create(GetTransactionReceiptRequest(hash: hash.to0x)), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                
                let value = responseValue as! [String: Any]
                let result = value["result"] as! [String: Any]
                
                let blockNumberString = result["blockNumber"] as! String
                let statusString = result["status"] as! String
                let blockNumber = BigInt(blockNumberString.drop0x, radix: 16) ?? BigInt(0)
                
                let receipt = TransactionReceipt(status: statusString == "0x1" ? true : false, blockNumber: blockNumber)
                
                completion(Result.success(receipt))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
    static func getBlockNumber(completion: @escaping (Result<BigInt>) -> Void) {
        
        ACNServiceRequest(batch: BatchFactory().create(BlockNumberRequest()), url: acnServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch ACNRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                
                let value = responseValue as! [String: Any]
                let result: String = value["result"] as! String
                let number = BigInt(result.drop0x, radix: 16) ?? BigInt()
                
                completion(Result.success(number))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
    
}
