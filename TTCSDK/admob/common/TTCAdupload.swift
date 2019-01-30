//
//  TTCAdupload.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/8.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import TTC_SDK_NET

class TTCAdupload {
    
    static let shared: TTCAdupload = TTCAdupload()
//    fileprivate let location = TTCLocationManager()
//
//    init() {
//        location.locate()
//    }
    
    func upload(adUnitID: String, handleType: Int32) {
        let behavior = TTCAdBehavior()
        behavior.adUnitID = adUnitID
        behavior.handleType = handleType
        behavior.countryCode = TTCManager.shared.location.countryCode
        TTCNetworkManager.uploadAdBehavior(behavior: behavior) { (success, error) in }
    }
}
