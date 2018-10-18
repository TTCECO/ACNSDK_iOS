//
//  TTCNetworkTransaction.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/6  下午12:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import APIKit
import Result
import JSONRPCKit
import BigInt
import TrustCore
import TTC_SDK_NET

class TTCRPCManager: NSObject {

    // MARK: - RPC request
    static func getEthBalance(for address: String, completion: @escaping (Result<Balance, SessionTaskError>) -> Void) {
        let request = TTCServiceRequest(batch: BatchFactory().create(BalanceRequest(address: address)), url: ttcServer.TTCURL)
        Session.send(request) { result in
            switch result {
            case .success(let balance):
                completion(.success(balance))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    /// fetch latest Nonce
    static func getTransactionCount(
        address: String,
        completion: @escaping (Result<BigInt, SessionTaskError>) -> Void
        ) {
        
        let request = TTCServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
            address: address,
            state: "latest"
        )))
        Session.send(request) { result in
            switch result {
            case .success(let count):
                completion(.success(count))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// fetch pending Nonce
    static func getTransactionPendingCount(
        address: String,
        completion: @escaping (Result<BigInt, SessionTaskError>) -> Void
        ) {
        
        let request = TTCServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
            address: address,
            state: "pending"
        )))
        Session.send(request) { result in
            switch result {
            case .success(let count):
                completion(.success(count))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// fetch version
    static func fetchVersion(complete: @escaping (Result<String, SessionTaskError>) -> Void) {
        
        let request = TTCServiceRequest(batch: BatchFactory().create(VersionRequest()))
        Session.send(request) { result in
            switch result {
            case .success(let string):
                complete(.success(string))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }

    static func sendTransaction(
        transaction: Transaction,
        completion: @escaping (Result<String, SessionTaskError>) -> Void
        ) {

        TTCRPCManager.signAndSend(transaction: transaction, completion: completion)
    }

    static private func signAndSend(
        transaction: Transaction,
        completion: @escaping (Result<String, SessionTaskError>) -> Void
        ) {
        let data = signTransaction(transaction)
        
        guard let signData = data else {
            completion(.failure(SessionTaskError.requestError(TTCRPCError.failedToSignTransaction)))
            return
        }
        TTCRPCManager.approve(transaction: transaction, data: signData, completion: completion)
    }

    static private func signTransaction(_ transaction: Transaction) -> Data? {
        let signer: Signer = EIP155Signer(chainId: BigInt(transaction.chainID))
        
        let hash = signer.hash(transaction: transaction)
        
        guard let keyData = Data(hexString: TTCManager.shared.privateKey ?? "") else {
            return nil
        }
        let signature = EthereumCrypto.sign(hash: hash, privateKey: keyData)
        let (r, s, v) = signer.values(transaction: transaction, signature: signature)
        let data = RLP.encode([
            transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            Data(hexString: transaction.to) ?? Data(),
            transaction.value,
            transaction.data,
            v, r, s
            ])
        return data
    }

    static private func approve(transaction: Transaction, data: Data, completion: @escaping (Result<String, SessionTaskError>) -> Void) {
        let dataHex = data.hexEncoded
        let request = TTCServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: dataHex)))
        Session.send(request) { result in
            switch result {
            case .success(let hex):
                completion(.success(hex))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func getTransaction(hash: String, completion: @escaping (Result<[String: AnyObject], SessionTaskError>) -> Void) {
        
        let request = TTCServiceRequest(batch: BatchFactory().create(GetTransactionRequest(hash: hash)))
        Session.send(request) { (result) in
            switch result {
            case .success(let dict):
                completion(.success(dict))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func getTransactionReceipt(hash: String, completion: @escaping (Result<TransactionReceipt, SessionTaskError>) -> Void) {
        
        let request = TTCServiceRequest(batch: BatchFactory().create(GetTransactionReceiptRequest(hash: hash)))
        Session.send(request) { (result) in
            switch result {
            case .success(let receipt):
                completion(.success(receipt))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
