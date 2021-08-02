//
//  ACNRPCRequest.swift
//  ACN_SDK
//
//  Created by zhangliang on 2018/7/4.
//  Copyright © 2018 tataufo. All rights reserved.
//

import Foundation
import Alamofire

enum ACNRPCError: Error {
    case getBalanceError
    case getBlockNumberError
    case getTransactionCountError
    case sendTransactionError
    case getTransactionReceiptError
    case RPCSuccessError(Int32, String)    // 网络成功，但是服务器返回业务错误
    case RPCError(Error)                   // 网路都没成功
    
    var errorDescription: String? {
        switch self {
        case .getBalanceError:
            return "Failed to get balance"
        case .getBlockNumberError:
            return "Get block number error"
        case .getTransactionCountError:
            return "Get Transaction count error"
        case .sendTransactionError:
            return "Send Transaction error"
        case .getTransactionReceiptError:
            return "Get Transaction Receipt Error"
        case .RPCSuccessError(_, let description):
            return description
        case .RPCError(let e):
            return e.localizedDescription
        }
    }
}
