//
//  ACNAdupload.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/8.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import ACN_SDK_NET

class ACNAdupload {
    
    static let shared: ACNAdupload = ACNAdupload()
//    fileprivate let location = ACNLocationManager()
//
//    init() {
//        location.locate()
//    }
    
    func upload(adUnitID: String, handleType: Int32) {
        let behavior = ACNAdBehavior()
        behavior.adUnitID = adUnitID
        behavior.handleType = handleType
        behavior.countryCode = ACNManager.shared.location.countryCode
        ACNNetworkManager.uploadAdBehavior(behavior: behavior) { _ in }
    }
}
