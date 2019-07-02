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
    
    var errorDescription: String? {
        switch self {
        case .connectError:
            return "Failed to connect"
        case .noContract:
            return "no contract"
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

    static let shared: ACNTokenManager = ACNTokenManager()
    
    fileprivate let global = DispatchQueue.global()
    fileprivate let main = DispatchQueue.main
    fileprivate var options: Web3Options = .default
    fileprivate var isConnecting = false //是否正在连接
    fileprivate var ancUrl = ""
    
    // 连接
    fileprivate func connet(_ count: Int32 = 3, complete: @escaping (Bool) -> Void) {
        
        if ancUrl != acnServer.ACNURL {
            self.isConnecting = false
        }
        
        if self.isConnecting {
            complete(true)
            return
        }
        
        if let url = URL(string: acnServer.ACNURL), let web = Web3(url: url) {
            Web3.default = web
            Web3.default.requestDispatcher.queue = DispatchQueue.global()
            ancUrl = url.absoluteString
            self.isConnecting = true
            complete(true)
        } else {
            self.isConnecting = false
            if count == 1 {
                complete(false)
            } else {
                self.connet(count-1, complete: complete)
            }
        }
    }
    
    // 余额
    func banlance(_ address: String, _ complete: @escaping (Result<BigUInt>) -> Void) {
        
        global.async {
            self.connet(complete: { (isConnect) in
                if isConnect {
                    do {
                        
                        if let exchange = self.getExchange(), let ACN = self.getACNContract() {
                            let from = Address(address.to0x)
                            
                            let contract = try Web3.default.contract(exchange.abi, at: Address(exchange.contractAddress.to0x))
                            let inter: TransactionIntermediate = try contract.method(exchangeMethod.balance.name, parameters: [Address(ACN.contractAddress.to0x), from], options: Web3Options.default)
                            let result: Web3Response = try inter.call(options: Web3Options.default)
                            
                            var balance: BigUInt = 0
                            let first = try result.uint256()
                            let second = try result.uint256()
                            balance = first+second
                            
                            self.main.async {
                                complete(Result.success(balance))
                            }
                            
                        } else {
                            self.main.async {
                                complete(Result.failure(ACNTokenError.noContract))
                            }
                        }
                    } catch let error {
                        self.main.async {
                            complete(Result.failure(error))
                        }
                    }
                } else {
                    self.main.async {
                        complete(Result.failure(ACNTokenError.connectError))
                    }
                }
            })
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
