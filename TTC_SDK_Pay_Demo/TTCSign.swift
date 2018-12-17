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

let TTCPrivateKey = "MIICXgIBAAKBgQCze4k/GOz+AjN053HzLQ9K9bMestBUoBF4Z7uVLxMhj+bo+keCI7X+LI9cPjI0IWmOQM+gY5/qgBnb5Eq4q9NARPh/YtyNQGiuLVtkdl+3lBTHGYY7enaBXG/psC5tFu+/R9GcnTQL8qF1PzKp7Mum19LXZK/hNTQA0ehA+h8JkQIDAQABAoGBAKsvOWD3+hnuqXtnwBQqtvpMy7GM5QzBusf3UD9ircGGCbvN8mQagVtSzs0w+RslfxLRl/Ym7wBve7pxzB7Eq295BJm6kM9iuZ6hY1uVAI1kVxugpHO5i+106NRnVGnXAE2ydfVpw/gsSM/cJl+L8RnlE3fyqagioPMorbFE0zMNAkEA3OyhnGzUTiudfvNI75pK8m0uZriAQ72/OiLhflDMSatBIgpC8Bgl0ikojCh5iPnjnVQCCVf+QeRabOVdxAtZLwJBAM/6hdGQ3iwqdSlH+VoONnjzfbfSAnfOLZGjE/spjwvD0f4R213jKeUMOt8jvxbuXuIGsuV5qczSJacbEV2pmT8CQQDGhVDYKqdAs0qsiFtzC3frjpbSsVp5BOnwiOWOR3a7gEtgFk5+R4S87EVGZRyJLNwPRS0rTkno1hU3o4h1oSj7AkAq7wOa/HXw1h7zk6kU/yQdmd5VCSR7SPO9QdYJHk4qVpVOBq+rVQ67+udYUw/KkxDBRjK+DnyQDL27HmpaVH2PAkEAxIYQAh4zalwTbttZA9wkvGkD9nrWpGNotgysquNCK4taYGxjG6CaybKjFz9U3drquJOtub553BO10jhD0+ZTxA=="

class TTCSign: NSObject {

    static func signOrder(order: TTCCreateOrder) -> String {
        
        var orderArray: [String] = []
        orderArray.append("outTradeNo=\(order.outTradeNo)")
        orderArray.append("description=\(order.description_p)")
        orderArray.append("totalFee=\(order.totalFee)")
        orderArray.append("partnerAddress=\(order.partnerAddress)")
        orderArray.append("createTime=\(order.createTime)")
        orderArray.append("expireTime=\(order.expireTime)")
        orderArray.append("payType=\(order.payType)")
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
