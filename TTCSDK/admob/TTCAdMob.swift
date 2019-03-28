//
//  TTCAdMob.swift
//  TTCSDK
//
//  Created by chenchao on 2018/12/28.
//  Copyright © 2018 tataufo. All rights reserved.
//

import GoogleMobileAds

public let TTCkAdSimulatorID = kGADSimulatorID

public class TTCAdMob: NSObject {
    
    /// Returns the shared TTCAdMob instance.
    @objc public static let sharedInstance: TTCAdMob = TTCAdMob()
    
    /// Initialize the Ads SDK.
    /// Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    @objc public static func configure(appID: String) {
        GADMobileAds.configure(withApplicationID: appID)
//        GADMobileAds.sharedInstance().start { (_) in }
        let _ = TTCAdupload.shared
    }
    
}
