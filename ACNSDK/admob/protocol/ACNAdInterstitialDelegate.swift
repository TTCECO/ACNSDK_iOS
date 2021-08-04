//
//  ACNInterstitialDelegate.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit

@objc public protocol ACNAdInterstitialDelegate {

    // MARK: - Ad Request Lifecycle Notifications
    
    /// Called when an interstitial ad request succeeded. Show it at the next transition point in your
    /// application such as when transitioning between view controllers.
    @objc optional func interstitialDidReceiveAd(ad: ACNAdInterstitial)
    
    /// Called when an interstitial ad request completed without an interstitial to
    /// show. This is common since interstitials are shown sparingly to users.
    @objc optional func interstitial(_: ACNAdInterstitial, didFailToReceiveAdWithError error: Error)
    
    // MARK: - Display-Time Lifecycle Notifications

    /// Tells the delegate that an impression has been recorded for the ad.
    @objc optional func interstitialDidRecordImpression(ad: ACNAdInterstitial)
    
    /// Tells the delegate that a click has been recorded for the ad.
    @objc optional func interstitialDidRecordClick(ad: ACNAdInterstitial)
    
    /// Tells the delegate that the ad failed to present full screen content.
    @objc optional func interstitial(ad: ACNAdInterstitial, didFailToPresentFullScreenContentWithError error: Error)
    
    /// Tells the delegate that the ad presented full screen content.
    @objc optional func interstitialDidPresentFullScreenContent(ad: ACNAdInterstitial)
    
    /// Tells the delegate that the ad will dismiss full screen content.
    @objc optional func interstitialWillDismissFullScreenContent(ad: ACNAdInterstitial)
    
    /// Tells the delegate that the ad dismissed full screen content.
    @objc optional func interstitialDidDismissFullScreenContent(ad: ACNAdInterstitial)

    
}
