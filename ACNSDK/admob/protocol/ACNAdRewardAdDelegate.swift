//
//  ACNAdRewardAdDelegate.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

/// Delegate for receiving state change messages from a ACNAdRewardAd such as ad requests
/// succeeding/failing.
@objc public protocol ACNAdRewardAdDelegate {

    /// Tells the delegate that the reward ad has rewarded the user.
    @objc optional func rewardAd(_ : ACNAdRewardAd, didRewardUserWithReward reward: ACNAdReward)
    
    /// Tells the delegate that the reward ad failed to load.
    @objc optional func rewardAd(_ : ACNAdRewardAd, didFailToLoadWithError error: Error)
    
    /// Tells the delegate that a reward ad was received.
    @objc optional func rewardAdDidReceiveAd(rewardAd: ACNAdRewardAd)
    
    /// Tells the delegate that an impression has been recorded for the ad.
    @objc optional  func rewardAdDidRecordImpression(rewardAd: ACNAdRewardAd)
    
    /// Tells the delegate that the reward clicked.
    @objc optional func rewardAdDidClicked(rewardAd: ACNAdRewardAd)
    
    /// Tells the delegate that the reward ad fail to present.
    @objc optional func rewardAd(_:  ACNAdRewardAd, didFailToPresentFullScreenContent error: Error)
    
    /// Tells the delegate that the reward ad did present full screen
    @objc optional func rewardAdDidPresentFullScreenContent(rewardAd: ACNAdRewardAd)
    
    /// Tells the delegate that the reward ad will dismiss full screen.
    @objc optional func rewardWillDismissFullScreenContent(rewardAd: ACNAdRewardAd)
    
    /// Tells the delegate that the reward ad did dismiss full screen.
    @objc optional func rewardAdDidDismissFullScreenContent(rewardAd: ACNAdRewardAd)
}
