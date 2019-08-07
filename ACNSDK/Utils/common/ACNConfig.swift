//
//  ACNConfig.swift
//  ACNSDK
//
//  Created by Zhang Yufei on 2018/7/19  下午1:58.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import Foundation
import ACN_SDK_NET

/// sdk version，modify when upgrading
let SDKVersion: Int32 = 1

struct ACNServer {
    let apiURL: String
    let actionURL: String
    let ACNURL: String
}

// api : 后台服务使用
// actionUR : 上传行为使用的链地址
// ACNURL : ACN余额的链地址
var acnServer = ACNServer(apiURL: "http://sdk.ttcnet.io/", actionURL: "http://test.ttcnet.io/", ACNURL: "http://test.ttcnet.io/")

var contracts: [ACNContract] = []

