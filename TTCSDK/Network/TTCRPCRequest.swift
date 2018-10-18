//
//  TTCRPCRequest.swift
//  TTC_SDK
//
//  Created by zhangliang on 2018/7/4.
//  Copyright © 2018 tataufo. All rights reserved.
//

import Foundation
import JSONRPCKit
import APIKit

enum TTCRPCError: Error {
    case getBalanceError
    case failedToSignTransaction
    
    var errorDescription: String? {
        switch self {
        case .getBalanceError:
            return "Failed to get balance"
        case .failedToSignTransaction:
            return "Failed to sign transaction"
        }
    }
}

struct TTCServiceRequest<Batch: JSONRPCKit.Batch>: APIKit.Request {
    let batch: Batch

    typealias Response = Batch.Responses

    var timeoutInterval: Double
    var url: String = ""

    init(batch: Batch, timeoutInterval: Double = 30.0, url: String = ttcServer.actionURL) {
        self.batch = batch
        self.timeoutInterval = timeoutInterval
        self.url = url
    }

    var baseURL: URL {
        return URL(string: self.url) ?? URL(fileURLWithPath: "")
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/"
    }

    var parameters: Any? {
        return batch.requestObject
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = timeoutInterval
        return urlRequest
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try batch.responses(from: object)
    }
}
