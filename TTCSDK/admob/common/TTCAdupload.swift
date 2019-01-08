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
    
    fileprivate let currencyCode = Locale.current.currencyCode ?? ""
    
    func upload(adUnitID: String, handleType: Int32) {
        let behavior = TTCAdBehavior()
        behavior.adUnitID = adUnitID
        behavior.handleType = handleType
        behavior.countryCode = currencyCode
        TTCNetworkManager.uploadAdBehavior(behavior: behavior) { (success, error) in
            print("")
        }
    }
}
