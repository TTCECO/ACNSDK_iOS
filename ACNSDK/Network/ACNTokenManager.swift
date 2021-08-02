//
//  ACNTokenManager.swift
//  ACNSDK
//
//  Created by chenchao on 2019/6/25.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import web3swift
import BigInt
import Alamofire
import ACN_SDK_NET

enum ACNTokenError: Error {
    case connectError
    case noContract
    case getBalanceError
    
    var errorDescription: String? {
        switch self {
        case .connectError:
            return "Failed to connect"
        case .noContract:
            return "no contract"
        case .getBalanceError:
            return "Get Balance error"
        }
    }
}

enum exchangeMethod {
    case balance
    var name: String {
        switch self {
        case .balance:
            return "getAccountBalance"
        }
    }
    
}

enum ACNERC20Method {
    case balance
    case transfer
    case approve
    case allowance
    case decimals
    
    var name: String {
        switch self {
        case .balance:
            return "balanceOf(address)"
        case .transfer:
            return "transfer(address,uint256)"
        case .approve:
            return "approve(address,uint256)"
        case .allowance:
            return "allowance(address,address)"
        case .decimals:
            return "decimals()"
        }
    }
}

class ACNTokenManager: NSObject {
    
    fileprivate var ancUrl = ""
    fileprivate var web3: web3?
    
    // 连接
    fileprivate func connet(complete: @escaping (Bool) -> Void) {
        
        if ancUrl != acnServer.ACNURL {
            
            self.web3 = nil
        }
        
        if web3 != nil {
            complete(true)
        } else if let url = URL(string: acnServer.ACNURL) {
            do {
                let web = try Web3.new(url)
                ancUrl = url.absoluteString
                self.web3 = web
                
                complete(true)
            } catch { // url正确时，不再重试
                
                complete(false)
            }
        } else {
            complete(false)
        }
    }
    
    
    
    // 余额
    func banlance(_ address: String, _ complete: @escaping (Result<BigUInt, ACNTokenError>) -> Void) {
        
        DispatchQueue.global().async {
            self.connet { [weak self] isConnect in
                if isConnect,
                   let web3 = self?.web3 {
                    
                    do {
                        
                        if let exchangeContract = self?.getExchange(),
                           let acnContract = self?.getACNContract() {
                            
                            
                            let contract = web3.contract(exchangeContract.abi,
                                                         at: EthereumAddress(exchangeContract.contractAddress.to0x))
                            let inter = contract?.method(exchangeMethod.balance.name,
                                                         parameters: [acnContract.contractAddress.to0x, address.to0x] as [AnyObject],
                                                         extraData: Data(),
                                                         transactionOptions: TransactionOptions.defaultOptions)
                            let result = try inter?.call(transactionOptions: .defaultOptions)
                            
                            var balance: BigUInt = 0
                            
                            if let first = result?["0"] as? BigUInt,
                               let second = result?["1"] as? BigUInt {
                                
                                balance = first + second
                                
                            } else if let firstStr = result?["0"] as? String,
                                      let secondStr = result?["1"] as? String,
                                      let first = BigUInt(firstStr),
                                      let second = BigUInt(secondStr) {
                                balance = first + second
                            }
                            
                            DispatchQueue.main.async {
                                complete(.success(balance))
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                complete(.failure(.noContract))
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            complete(.failure(.getBalanceError))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        complete(.failure(.connectError))
                    }
                }
            }
        }
    }
}


extension ACNTokenManager {
    
    // 获取交易所合约
    func getExchange() -> ACNContract? {
        return self.getContract("exchange")
    }
    
    // 获取acn合约
    func getACNContract() -> ACNContract? {
        return self.getContract("acn")
    }
    
    // 找到合约
    func getContract(_ name: String) -> ACNContract? {
        
        for contract in contracts {
            if contract.name.lowercased() == name {
                return contract
            }
        }
        
        return nil
    }
    
    
}
