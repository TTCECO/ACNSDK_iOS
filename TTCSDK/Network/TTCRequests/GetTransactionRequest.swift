// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import JSONRPCKit
import TrustCore

struct GetTransactionRequest: JSONRPCKit.Request {
    typealias Response = [String: AnyObject]

    let hash: String

    var method: String {
        return "eth_getTransactionByHash"
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
/*
 该协议返回的dict 键值
 ["交易详情:
 blockNumber: QUANTITY - 交易所在块的编号，对于挂起块，该值为null
 [\"blockNumber\": 0x2fa27,
 blockHash: DATA, 32字节 - 交易所在块的哈希，对于挂起块，该值为null
 \"blockHash\": 0x74594235dfdb9a5e30244df13daecf9a4317a8cef749abb0d0316529d4777966,
 transactionIndex: QUANTITY - 交易在块中的索引位置，挂起块该值为null
 \"transactionIndex\": 0x6,
 input: DATA - 随交易发送的数据
 \"input\": 0x75666f3a313a6f706c6f673a6d64353a3266313863373033396235616638373131663330316261633565633435323665,
 value: QUANTITY - 发送的以太数量，单位：wei
 \"value\": 0x0,
 hash: DATA, 32字节 - 交易哈希
 \"hash\": 0x98de40351fd6ff959917dd6633dfa5ae23718e272cd3cdd1c9cc6e471d1d136c,
 from: DATA, 20字节 - 交易发送方地址
 \"from\": 0xa600951b297f5e537b53602cbf4c178436415b2a,
 to: DATA, 20字节 - 交易接收方地址，对于合约创建交易，该值为null
 \"to\": 0xa6aac51be7cd96412896d5efa2b8c0cf72d340ba,
 gasPrice: QUANTITY - 发送方提供的gas价格，单位：wei
 \"gasPrice\": 0x746a528800,
 gas: QUANTITY - 发送方提供的gas可用量
 \"gas\": 0x5ec8]
 nonce: QUANTITY - 本次交易之前发送方已经生成的交易数量
 \"nonce\": 0x266,
 \"v\": 0x80f,
 \"r\": 0x757fc3fddec46bf1fb41090adf2e88ed9ff1332b80073b2a495a03f03319a7f,
 \"s\": 0x2941c3ca98a92ccbef3d9500716660884b363e151bc67fd2d465b16cffa9d465,
 "]
 */
