//
//  ACNAdMob.swift
//  ACNSDK
//
//  Created by chenchao on 2018/12/28.
//  Copyright © 2018 tataufo. All rights reserved.
//

import GoogleMobileAds

public let ACNkAdSimulatorID = kGADSimulatorID

public class ACNAdMob: NSObject {
    
    /// Returns the shared ACNAdMob instance.
    @objc public static let sharedInstance: ACNAdMob = ACNAdMob()
    
    /// Initialize the Ads SDK.
    /// Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    @objc public static func configure(appID: String) {
        GADMobileAds.configure(withApplicationID: appID)
//        GADMobileAds.sharedInstance().start { (_) in }
        let _ = ACNAdupload.shared
    }
    
}
