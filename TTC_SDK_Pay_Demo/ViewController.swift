//
//  ViewController.swift
//  TTC_SDK_Pay_Demo
//
//  Created by chenchao on 2018/12/17.
//  Copyright © 2018 tataufo. All rights reserved.
//

import UIKit
import TTCPay
import SwiftyRSA

enum LatiaoType: Int32 {
    case Normal = 0     // 一般辣
    case No     = 1     // 不辣
    case Spicy  = 2     // 特别辣
    
    var name: String {
        switch self {
        case .No:
            return "一般辣的"
        case .Normal:
            return "不怎么辣的"
        case .Spicy:
            return "特别特别辣的"
        }
    }
}

enum shangjiaType: Int32 {
    case superJia       = 0     // 一般辣
    case chaorenJia     = 1     // 不辣
    case zhaocaiJia     = 2     // 特别辣
    
    var name: String {
        switch self {
        case .superJia:
            return "super家"
        case .chaorenJia:
            return "超人家"
        case .zhaocaiJia:
            return "招财家"
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    var createOrder: TTCCreateOrder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        TTCPay.shared.fetchPrice(currencyType: 4) { (success, value, error) in
            if success {
                print(value ?? "")
            } else {
                print(error?.errorDescription ?? "")
            }
        }
    }
    
    @IBAction func createClick(_ sender: Any) {
        
        let createTime: Int64 = Int64(Date().timeIntervalSince1970*1000)
        
        let max: UInt32 = 100
        let min: UInt32 = 1
        let count = arc4random() % max + min
        let num = arc4random()
        let type = arc4random()%3
        let jia = arc4random()%3
        
        let jiaType: shangjiaType = shangjiaType(rawValue: Int32(jia))!
        let latiaoType: LatiaoType = LatiaoType(rawValue: Int32(type))!
        let unit: Int64 = 1000000000000
        let total: Int64 = unit*Int64(count)
        
        let createOrder = TTCCreateOrder()
        createOrder.appId = TTCPay.shared.appId
        createOrder.createTime = createTime
        createOrder.expireTime = createTime+60*15*1000 // 15分钟
        createOrder.description_p = "\(jiaType.name)，\(latiaoType.name)辣条，\(count)包"
        createOrder.outTradeNo = num.description
        createOrder.totalFee = total.description
        createOrder.requestSign = TTCSign.signOrder(order: createOrder)
        
        self.createOrder = createOrder
        
        stateLabel.textColor = UIColor.black
        stateLabel.text = "下单成功"
        textLabel.text = "\(createOrder.description_p)"
        
        print(createOrder.description_p)
        
    }
    
    
    @IBAction func pay(_ sender: Any) {
        
        guard let order = createOrder else {
            textLabel.text = "请先下单，再支付！"
            stateLabel.text = "请先下单，再支付！"
            stateLabel.textColor = UIColor.black
            return
        }
        
        self.stateLabel.textColor = UIColor.blue
        stateLabel.text = "支付中..."
        
        TTCPay.shared.createOrderAndPay(createOrder: order) { (success, orderResult, error) in
            if success, orderResult != nil {
                print("create success : \(orderResult!.orderId.description)")
                self.createOrder = nil
            } else {
                print("create failed：%@", error?.errorDescription ?? "")
            }
        }
        
        TTCPay.shared.payBack = { success, order, error in
            if success, order != nil, !order!.txHash.isEmpty {
                self.textLabel.text = order!.txHash
                self.stateLabel.textColor = UIColor.green
                self.stateLabel.text = "支付成功"
                print("txhash: ",order?.txHash ?? "txhash")
            } else {
                self.stateLabel.textColor = UIColor.red
                self.stateLabel.text = "支付失败"
                print(error?.errorDescription ?? "error")
            }
        }
    }
}


