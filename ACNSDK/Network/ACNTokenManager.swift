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

enum ACNTokenError: Error {
    case connectError
    
    var errorDescription: String? {
        switch self {
        case .connectError:
            return "Failed to connect"
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
    fileprivate let tokenAddress: Address
    fileprivate var options: Web3Options = .default
    fileprivate var isConnecting = false //是否正在连接
    fileprivate var ancUrl = ""
    
    override init() {
        
        let address: String = acnContractAddress
        
        tokenAddress = Address(address)
    }
    
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
                        
//                        if self.tokenAddress {
//
//                        }
                        
                        let from = Address(address)
                        let banlance = try self.tokenAddress.call(ACNERC20Method.balance.name, from, options: self.options).wait().uint256()
                        
                        self.main.async {
                            complete(Result.success(banlance))
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
