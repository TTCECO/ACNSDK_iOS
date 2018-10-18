//
//  user.swift
//  TTC_SDK_iOS_Demo
//
//  Created by Zhang Yufei on 2018/7/17  下午6:36.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import Foundation


class TTCUser {
    
    static let shared = TTCUser()
    
    public var userId: String?
    public var nickname: String?
    public var avatarUrl: String?
    /// value = male / female
    public var gender: String?
    public var telephone: String?
    public var email: String?
    
    /// dapp user's address
    public var address: String?
    /// bound wallet's address
    public var wallet: String?
    
    
}
