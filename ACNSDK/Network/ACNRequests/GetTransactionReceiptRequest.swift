// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import TrustCore
import BigInt

struct TransactionReceipt: Encodable {
    let status: Bool
    let blockNumber: BigInt
}

struct GetTransactionReceiptRequest: JSONRPCKit.Request {
    typealias Response = [String: AnyObject]

    let hash: String
    var method: String {
        return "eth_getTransactionReceipt"
    }
    var parameters: Any? {
        return [hash]
    }

    func response(from resultObject: Any) throws -> Response {
        guard
            let dict = resultObject as? [String: AnyObject]
            else {
                throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
        return dict
    }
}

struct BlockNumberRequest: JSONRPCKit.Request {
    typealias Response = String
    
    var method: String {
        return "eth_blockNumber"
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
