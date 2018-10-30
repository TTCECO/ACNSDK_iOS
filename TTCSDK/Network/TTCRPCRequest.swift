//
//  TTCRPCRequest.swift
//  TTC_SDK
//
//  Created by zhangliang on 2018/7/4.
//  Copyright © 2018 tataufo. All rights reserved.
//

import Foundation
import JSONRPCKit
import Alamofire

enum TTCRPCError: Error {
    case getBalanceError
    case failedToSignTransaction
    case RPCSuccessError(Int32, String)    // 网络成功，但是服务器返回业务错误
    case RPCError(Error)                   // 网路都没成功
    
    var errorDescription: String? {
        switch self {
        case .getBalanceError:
            return "Failed to get balance"
        case .failedToSignTransaction:
            return "Failed to sign transaction"
        case .RPCSuccessError(_, let description):
            return description
        case .RPCError(let e):
            return e.localizedDescription
        }
    }
}

class TTCServiceRequest<Batch: JSONRPCKit.Batch>: NSObject {
    
    let batch: Batch
    let url: String
    
    init(batch: Batch, url: String) {
        self.batch = batch
        self.url = url
    }
    
    func getRequest() -> DataRequest? {
        
        let patameter = batch.requestObject as? [String: Any]
        
        return Alamofire.request(url, method: HTTPMethod.post, parameters: patameter, encoding: JSONEncoding.default, headers: nil)
    }
    
}
