//
//  VersionRequest.swift
//  TTC_Wallet_iOS
//
//  Created by chenchao on 2018/7/20.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit
import JSONRPCKit
import BigInt

struct VersionRequest: JSONRPCKit.Request {
    typealias Response = String
    
    var method: String {
        return "net_version"
    }
    
    var parameters: Any? {
        return []
    }
    
    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
