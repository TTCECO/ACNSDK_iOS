//
//  TTCConfig.swift
//  TTCSDK
//
//  Created by Zhang Yufei on 2018/7/19  下午1:58.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import Foundation

/// sdk version，modify when upgrading
let SDKVersion: Int32 = 1
let actionTypeLogin: Int32 = 112

struct TTCServer {
    let apiURL: String
    let actionURL: String
    let TTCURL: String
}

// api : 后台服务使用
// actionUR : 上传行为使用的链地址
// TTCURL : ttc余额的链地址
var ttcServer = TTCServer(apiURL: "http://sdk.ttcnet.io/", actionURL: "http://test.ttcnet.io/", TTCURL: "http://test.ttcnet.io/")




