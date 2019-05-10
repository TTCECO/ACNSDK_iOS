//
//  ACNAdReward.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import GoogleMobileAds

/// Reward information for ACNAdRewardBasedVideoAd ads.
@objc public class ACNAdReward: NSObject {

    var reward: GADAdReward!
    
    /// Type of the reward.
    @objc public var rewardType: String? {
        get {
            return reward.type
        }
    }
    
    /// Amount rewarded to the user.
    @objc public var amount: NSDecimalNumber? {
        get {
            return reward.amount
        }
    }
    
    init(reward: GADAdReward) {
        super.init()
        self.reward = reward
    }
}
