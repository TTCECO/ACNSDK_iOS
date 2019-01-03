//
//  TTCAdRewardBasedVideoAdDelegate.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

/// Delegate for receiving state change messages from a TTCAdRewardBasedVideoAd such as ad requests
/// succeeding/failing.
@objc public protocol TTCAdRewardBasedVideoAdDelegate {

    /// Tells the delegate that the reward based video ad has rewarded the user.
    func rewardBasedVideoAd(rewardBasedVideoAd: TTCAdRewardBasedVideoAd, didRewardUserWithReward reward: TTCAdReward)
    
    /// Tells the delegate that the reward based video ad failed to load.
    @objc optional func rewardBasedVideoAd(rewardBasedVideoAd: TTCAdRewardBasedVideoAd, didFailToLoadWithError error: Error)
    
    /// Tells the delegate that a reward based video ad was received.
    @objc optional func rewardBasedVideoAdDidReceiveAd(rewardBasedVideoAd: TTCAdRewardBasedVideoAd)
    
    /// Tells the delegate that the reward based video ad opened.
    @objc optional func rewardBasedVideoAdDidOpen(rewardBasedVideoAd: TTCAdRewardBasedVideoAd)
    
    /// Tells the delegate that the reward based video ad started playing.
    @objc optional func rewardBasedVideoAdDidStartPlaying(rewardBasedVideoAd: TTCAdRewardBasedVideoAd)
    
    /// Tells the delegate that the reward based video ad completed playing.
    @objc optional func rewardBasedVideoAdDidCompletePlaying(rewardBasedVideoAd: TTCAdRewardBasedVideoAd)
    
    /// Tells the delegate that the reward based video ad closed.
    @objc optional func rewardBasedVideoAdDidClose(rewardBasedVideoAd: TTCAdRewardBasedVideoAd)

    /// Tells the delegate that the reward based video ad will leave the application.
    @objc optional func rewardBasedVideoAdWillLeaveApplication(rewardBasedVideoAd: TTCAdRewardBasedVideoAd)
}
