//
//  ACNNetworkTransaction.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/6  下午12:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation
import BigInt
import ACN_SDK_NET
import Alamofire
import web3swift
import PromiseKit

enum RPCErrorType: Int32 {
    case null = 133
    case NotDic = 132
    case NotGetError = 131
    case NotInt = 130
}

class ACNRPCManager: NSObject {
    
    let web: web3
    
    init?(url: URL) {
        do {
            let web3 = try Web3.new(url)
            self.web = web3
        } catch {
            return nil
        }
    }
    
    func getEthBalance(for address: String, completion: @escaping (Swift.Result<BigUInt, ACNRPCError>) -> Void) {
        
        DispatchQueue.global().async {
            
            if let addr = EthereumAddress(address.to0x) {
                
                do {
                    let balance = try self.web.eth.getBalance(address: addr)
                    completion(.success(balance))
                } catch {
                    completion(.failure(.getBalanceError))
                }
            } else {
                completion(.failure(.getBalanceError))
            }
        }
    }
}

class ACNActionRPCManager: NSObject {
    
    let web: web3
    
    init?(url: URL, privateKey: Data) {
        do {
            let web3 = try Web3.new(url)
            
            if let eKeyStore = try EthereumKeystoreV3(privateKey: privateKey,
                                                      password: "LocalDefaultPassword") {
                let keystore = KeystoreManager([eKeyStore])
                web3.addKeystoreManager(keystore)
                self.web = web3
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func getSideBalance(for address: String,
                        completion: @escaping (Swift.Result<BigUInt, ACNRPCError>) -> Void) {
        
        DispatchQueue.global().async {
            
            if let addr = EthereumAddress(address.to0x) {
                
                do {
                    let balance = try self.web.eth.getBalance(address: addr)
                    completion(.success(balance))
                } catch {
                    completion(.failure(.getBalanceError))
                }
            } else {
                completion(.failure(.getBalanceError))
            }
        }
    }
    
    /// fetch latest Nonce
    func getTransactionCount(address: String,
                             completion: @escaping (Swift.Result<BigInt, ACNRPCError>) -> Void) {
        
        DispatchQueue.global().async {
            
            if let addr = EthereumAddress(address.to0x) {
                
                do {
                    let transactionCount = try self.web.eth.getTransactionCount(address: addr)
                    completion(.success(BigInt(transactionCount)))
                } catch {
                    completion(.failure(.getTransactionCountError))
                }
            } else {
                completion(.failure(.getTransactionCountError))
            }
        }
    }
    
    /// fetch pending Nonce
    func getTransactionPendingCount(address: String,
                                    completion: @escaping (Swift.Result<BigInt, ACNRPCError>) -> Void) {
        
        DispatchQueue.global().async {
            
            if let addr = EthereumAddress(address.to0x) {
                
                do {
                    let transactionCount = try self.web.eth.getTransactionCount(address: addr, onBlock: "pending")
                    completion(.success(BigInt(transactionCount)))
                } catch {
                    completion(.failure(.getTransactionCountError))
                }
            } else {
                completion(.failure(.getTransactionCountError))
            }
        }
    }
    
    func sendTransaction(from: EthereumAddress,
                         to: EthereumAddress,
                         gasLimit: BigUInt,
                         gasPrice: BigUInt,
                         value: BigUInt,
                         nonce: BigUInt,
                         data: Data,
                         completion: @escaping (Swift.Result<String, ACNRPCError>) -> Void) {
        
        DispatchQueue.global().async {
            do {
                var trans = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: data)
                trans.nonce = nonce
                trans.UNSAFE_setChainID(self.web.provider.network?.chainID)
                
                var options = TransactionOptions()
                options.callOnBlock = .pending
                options.from = from
                options.nonce = .manual(nonce)
                options.gasLimit = .manual(gasLimit)
                options.gasPrice = .manual(gasPrice)
                
                let result = try self.web.eth.sendTransaction(trans, transactionOptions: options, password: "LocalDefaultPassword")
                completion(.success(result.hash))
            } catch {
                completion(.failure(.sendTransactionError))
            }
        }
    }
    
    func getTransactionReceipt(txhash: String,
                               completion: @escaping (Swift.Result<TransactionReceipt, ACNRPCError>) -> Void) {
        DispatchQueue.global().async {
            do {
                let result = try self.web.eth.getTransactionReceipt(txhash.to0x)
                completion(.success(result))
            } catch {
                completion(.failure(.getTransactionReceiptError))
            }
        }
    }
    
    func getBlockNumber(completion: @escaping (Swift.Result<BigUInt, ACNRPCError>) -> Void) {
        
        DispatchQueue.global().async {
            do {
                let result = try self.web.eth.getBlockNumber()
                completion(.success(result))
            } catch {
                completion(.failure(.getBlockNumberError))
            }
        }
    }
    
}
