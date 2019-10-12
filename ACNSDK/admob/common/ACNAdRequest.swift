//
//  ACNAdRequest.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import GoogleMobileAds

public class ACNAdRequest: NSObject {
    
    @objc public static func request() -> ACNAdRequest {
        return ACNAdRequest()
    }
    
    var gadRequest: GADRequest = GADRequest()
    
    @objc public var testDevices: NSArray? {
        didSet {
            gadRequest.testDevices = testDevices as? [String]
        }
    }
}
