//
//  TTCConstant.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/12  下午6:26.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import Foundation

let isIphonex: Bool = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) >= 812

let iPhoneXNavBarOffset: CGFloat = isIphonex ? 24.0 : 0.0

let keychainKeyPrefix = "TTCSDKKEY"
