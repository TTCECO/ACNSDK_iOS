//
//  TTCAdRequest.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import GoogleMobileAds

public class TTCAdRequest: NSObject {
    
    @objc public static func request() -> TTCAdRequest {
        return TTCAdRequest()
    }
    
    var gadRequest: GADRequest = GADRequest()
    
    @objc public var testDevices: NSArray? {
        didSet {
            gadRequest.testDevices = testDevices as? [Any]
        }
    }
}
