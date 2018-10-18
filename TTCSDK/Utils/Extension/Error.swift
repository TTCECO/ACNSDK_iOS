//
//  help.swift
//  TTCSDK
//
//  Created by chenchao on 2018/8/3.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit
import TTC_SDK_NET

enum TTCErrorType: Int {
    case APPIDNull = 100
    case SecretKeyNull = 101
    case UserIDNull = 102
    case RegisterNo = 103
    case SDKDisable = 104
    case UserChanged = 105
    case LoginNo = 106
    case Unbind = 107
    case ExtraNull = 108
    case ExtraNotJson = 109
    case ActionType100 = 110
}

extension TTCSDKError {
    
    convenience init(type: TTCErrorType) {
        var desc = ""
        switch type {
        case .APPIDNull:
            desc = "appId cannot be empty" // appId 不能为空
        case .SecretKeyNull:
            desc = "SecretKey cannot be empty" // SecretKey 不能为空
        case .UserIDNull:
            desc = "userID cannot be empty" // userID 不能为空
        case .RegisterNo:
            desc = "SDK is not registered, please register" // 还没有注册SDK，请调用注册接口
        case .SDKDisable:
            desc = "SDK is disabled" // SDK当前处理disabled状态,打开请调用SDKEnable()
        case .UserChanged:
            desc = "Update information must be current user" // 更新用户信息必须是当前用户
        case .LoginNo:
            desc = "No logged in user" // 用户还没有登录/没有登录用户
        case .Unbind:
            desc = "no binded wallet" // 当前用户尚未绑定钱包
        case .ExtraNull:
            desc = "Extra is empty" // extra不能为空
        case .ExtraNotJson:
            desc = "Extra is not json" // extra必须是json格式
        case .ActionType100:
            desc = "Behavior less than 100" // 行为类型必须大于100
        }
        self.init(code: "\(type.rawValue)", description: desc)
    }

    convenience init(code: String = "300", description: String) {
        self.init()

        self.code = code
        self.errorDescription = description
    }

    convenience init?(error: TTCInternalError?) {
        if let err = error {
            self.init(code: err.code, description: err.errorDescription)
        } else {
            return nil
        }
    }
}
