//
//  TTCAdMob.swift
//  TTCSDK
//
//  Created by chenchao on 2018/12/28.
//  Copyright © 2018 tataufo. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class TTCAdMob: NSObject {

    /// Initialize the Ads SDK.
    /// Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    @objc public static func configure(appID: String) {
        GADMobileAds.configure(withApplicationID: appID)
    }
    
    
}
