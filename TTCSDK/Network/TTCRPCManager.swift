//
//  TTCNetworkTransaction.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/6  下午12:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import JSONRPCKit
import BigInt
import TrustCore
import TTC_SDK_NET
import Alamofire

enum RPCErrorType: Int32 {
    case null = 133
    case NotDic = 132
    case NotGetError = 131
    case NotInt = 130
}

class TTCRPCManager: NSObject {
    
    // 解析error
    static func isRespondError(result: Result<Any>) -> Result<Any> {
        switch result {
        case .success(let resultValue):
            
            if resultValue is NSNull {
                return Result.failure(TTCRPCError.RPCSuccessError(RPCErrorType.null.rawValue, "null"))
            }
            
            guard let value = resultValue as? [String: Any] else {
                return Result.failure(TTCRPCError.RPCSuccessError(RPCErrorType.NotDic.rawValue, "Can't as [String: Any]"))
            }
            
            if let e = value["error"] {
                if let error = e as? [String: Any] {
                    let message = error["message"] as! String
                    let code: Int32 = error["code"] as! Int32
                    return Result.failure(TTCRPCError.RPCSuccessError(code, message))
                } else {
                    return Result.failure(TTCRPCError.RPCSuccessError(RPCErrorType.NotGetError.rawValue, "Failed to get error"))
                }
            } else {
                
                if value["result"] is NSNull {
                    return Result.failure(TTCRPCError.RPCSuccessError(RPCErrorType.null.rawValue, "null"))
                }
            
                return Result.success(value)
            }
            
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    // MARK: - RPC request
    static func getEthBalance(for address: String, completion: @escaping (Result<Balance>) -> Void) {
        TTCServiceRequest(batch: BatchFactory().create(BalanceRequest(address: address.to0x)), url: ttcServer.TTCURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
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
        
        TTCServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: address.to0x, state: "latest")), url: ttcServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
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
        
        TTCServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: address.to0x, state: "pending")), url: ttcServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
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
        
        TTCServiceRequest(batch: BatchFactory().create(VersionRequest()), url: ttcServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
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
        TTCRPCManager.signAndSend(transaction: transaction, completion: completion)
    }
    
    static private func signAndSend(transaction: Transaction, completion: @escaping (Result<String>) -> Void) {
        let data = signTransaction(transaction)
        
        guard let signData = data else {
            completion(Result.failure(TTCRPCError.failedToSignTransaction))
            return
        }
        
        TTCRPCManager.approve(transaction: transaction, data: signData, completion: completion)
    }
    
    static private func signTransaction(_ transaction: Transaction) -> Data? {
        let signer: Signer = EIP155Signer(chainId: BigInt(transaction.chainID))
        
        let tmptrans = Transaction.init(from: transaction.from.to0x, to: transaction.to.to0x, gasLimit: transaction.gasLimit, gasPrice: transaction.gasPrice, value: transaction.value, nonce: transaction.nonce, data: transaction.data, chainID: transaction.chainID)
        
        let hash = signer.hash(transaction: tmptrans)
        
        guard let keyData = Data(hexString: TTCManager.shared.privateKey ?? "") else {
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
        TTCServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: dataHex)), url: ttcServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
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
        
        TTCServiceRequest(batch: BatchFactory().create(GetTransactionRequest(hash: hash.to0x)), url: ttcServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
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
        
        TTCServiceRequest(batch: BatchFactory().create(GetTransactionReceiptRequest(hash: hash.to0x)), url: ttcServer.actionURL).getRequest()?.validate().responseJSON(completionHandler: { response in
            
            switch TTCRPCManager.isRespondError(result: response.result) {
            case .success(let responseValue):
                
                let value = responseValue as! [String: Any]
                let gasUsedString = value["gasUsed"] as! String
                let statusString = value["status"] as! String
                let gasUsed = BigInt(gasUsedString.drop0x, radix: 16) ?? BigInt(0)
                let receipt = TransactionReceipt(gasUsed: gasUsed.description, status: statusString == "0x1" ? true : false )
                
                completion(Result.success(receipt))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }
}
