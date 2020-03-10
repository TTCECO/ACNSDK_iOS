//
//  TTCSign.swift
//  TTCPayDemo
//
//  Created by chenchao on 2018/12/14.
//  Copyright © 2018 chenchao. All rights reserved.
//

import UIKit
import SwiftyRSA
import TTCPay

//let TTCPrivateKey = "MIICXAIBAAKBgQDm+UWKrZ1+gO3+8UMz4ELR+vsKxRxfH61hBlhIdsTqpCeyxrgyKOfadEITa2qNK5uCXR6Z/8TxMKnqhojE0FgnG9n36J2yz3aAJlG9cQ6kY+1D8dQJoAcTBHIjIOj+6EYcCsfd7P8ChkKjRTF5737azFopmeiyy28BfEs4/byHEwIDAQABAoGAWg+EUCiWKod3RVspiwa8x0eHr5FgGK8vWY+xyL+W1K8hU5IsrFJK5WFDinLt3xHL1y8cCYwzbKA/ANVoauWaGRgeBvQygrp8XIjL1/dm8O6dgNI2kr5QxZ0uFs6M8J+K7gnsw7TItpb0BnzxTDtCsOXoo8LtZr/R3jt/9Or4brECQQD1AfDjojg/jvNc6Qd/dbOAx5C6fsmpbqhIwbqX2AGhm6v44d7P4Q19tnmbmK0Ojg/X9tsejNHqQPO0UadxTCSXAkEA8VYksMbBOBiHGt8iyW+p2BVBkyTflMjTGea/AR/niDphb2DcanjJYNcK+ki0Y5stZ9Hommculkd1fmu6wNwU5QJAC6+6A8GbGT0CUq4y01uT4lKijqK5j8FdeYr0EYYWHdVFEKwFarj7YcGwb0GLD6SrEMwPi5d/88KBXVp/uCG/pQJAPZPvVLPCBWAsyOx6Yc9+FMaHrtXPvpTnWEqKHe1YFGhhCBw84WXkbDMyd94pOOkVUtI6eXsuZeXh0toGEsOVCQJBAOJEjU1JwVa0Pil0+/yiQM3us2N7YR0yk/LPUOK8l91RJK9SxU01N8G36DKWBQMyK5dW0WshEwezziFnlCBOuJ8="

let TTCPrivateKey = "MIICXgIBAAKBgQD2svJIMERV6ATSMCHSFE0QN2AVX2F0+azRl6iR3ztcI/DfHc6XcDVVJFaVlI1oJEF45fQHmmMv+RCAa9pX0AfKITiZYsdq0jLzde/yX7jszL3ot/eFGvFVbrXwvk8s4RZ2kA5OXRo8PqEbg6aoceZ5FSSuxqu+8NZprKL4V5jwLwIDAQABAoGBAKeXxbR45dOefbf07uTy2a+Mjv+1/lUjUN5KM0B18LOVzwskCrciiXi/6PpRIwd+qePiBDguD/gFMcqsenZxYvf+xmnwPkUrR0BSH5OXxW9Wqw2On6WEggLpn7pZGxrk1xuXFo4hYZHpVwllSS7NlsFGyNU9QhebckWYvhl1M2yhAkEA/aSyCjJIv7LBuSFQ7Av0j61rja583r9mvay6rdhBMQLjh0Qr8MCeU3zA3PJOgyvru+O79orRUuK2WXBrxGU8RwJBAPj9u8TdXhfPshSTQhYv0i9GE8sMI6N6iOhhqEbftUJJXlodxDdWTCYV0F/H9UrMuoLzqzbCA6dNViKcq1pUaNkCQQDiyqtjEJkZxxUOmqqHlR0EhxS/J4CBjvSnrlVw8gdAcovNO/hqGWC317l/Fa17/f6XDsbXaEJIcWyIxkul3LsrAkAKSdG8bLk6mqZtGzib2hYBRhADT9kZJDMMBx0A8LV4q7duWdSFxNcYq8YUbxq/oH4EczUb6iBkhVmNzJN4BAzhAkEA9qSkgvhAdJODgYrsy7t+fndXUpdDqxVJceh45icCB8Ql4KOsmJhDXNWCr3Py0X3KvVC+PAa4CJrudPz7RFXUgA=="

class TTCSign: NSObject {

    static func signOrder(order: TTCCreateOrder) -> String {
        
        var orderArray: [String] = []
        orderArray.append("outTradeNo=\(order.outTradeNo)")
        orderArray.append("description=\(order.description_p)")
        orderArray.append("totalFee=\(order.totalFee)")
        orderArray.append("partnerAddress=\(order.partnerAddress)")
        orderArray.append("createTime=\(order.createTime)")
        orderArray.append("expireTime=\(order.expireTime)")
        orderArray.append("payType=\(order.payType.rawValue)")
        orderArray.append("sellerDefinedPage=\(order.sellerDefinedPage)")
        orderArray.append("appId=\(order.appId)")
        
        let orderSortArray = orderArray.sorted()
        let resultString = orderSortArray.joined(separator: "&")
        
        let signString = TTCSign.sign(text: resultString)
        
        return signString
    }
    
    static func sign(text: String) -> String {
        do {
            if let data = Data(base64Encoded: TTCPrivateKey) {
                
                let preSignText = try ClearMessage(string: text, using: .utf8)
                let sign = try preSignText.signed(with: PrivateKey(data: data), digestType: .sha1)
                return sign.base64String
            } else {
                return ""
            }
        } catch let error {
            print(error.localizedDescription)
            return ""
        }
    }
}
