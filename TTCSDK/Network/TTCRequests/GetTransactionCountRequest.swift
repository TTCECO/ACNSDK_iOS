// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import JSONRPCKit

struct GetTransactionCountRequest: JSONRPCKit.Request {
    typealias Response = BigInt

    let address: String
    let state: String

    var method: String {
        return "eth_getTransactionCount"
    }

    var parameters: Any? {
        return [
            address,
            state
        ]
    }

    func response(from resultObject: Any) throws -> Response {
        
        if let responseStr = resultObject as? String, let response = BigInt(responseStr.drop0x, radix: 16) {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
