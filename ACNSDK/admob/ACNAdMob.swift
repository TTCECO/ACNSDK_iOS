//
//  ACNAdMob.swift
//  ACNSDK
//
//  Created by chenchao on 2018/12/28.
//  Copyright © 2018 tataufo. All rights reserved.
//

import GoogleMobileAds

public class ACNAdMob: NSObject {
    
    /// Initialize the Ads SDK.
    /// Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    @objc public class func start() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    @objc public class func config(testDeviceIdentifiers: [String]) {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers
    }
    
}
