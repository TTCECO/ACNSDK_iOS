//
//  TTCInterstitialDelegate.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit

@objc public protocol TTCAdInterstitialDelegate {

    // MARK: - Ad Request Lifecycle Notifications
    
    /// Called when an interstitial ad request succeeded. Show it at the next transition point in your
    /// application such as when transitioning between view controllers.
    func interstitialDidReceiveAd(ad: TTCAdInterstitial)
    
    /// Called when an interstitial ad request completed without an interstitial to
    /// show. This is common since interstitials are shown sparingly to users.
    func interstitialDidFailToReceiveAdWithError(ad: TTCAdInterstitial, error: Error)
    
    // MARK: - Display-Time Lifecycle Notifications
    
    /// Called just before presenting an interstitial. After this method finishes the interstitial will
    /// animate onto the screen. Use this opportunity to stop animations and save the state of your
    /// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
    /// Store from a link on the interstitial).
    func interstitialWillPresentScreen(ad: TTCAdInterstitial)
    
    /// Called when |ad| fails to present.
    func interstitialDidFailToPresentScreen(ad: TTCAdInterstitial)
    
    /// Called before the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(ad: TTCAdInterstitial)
    
    /// Called just after dismissing an interstitial and it has animated off the screen.
    func interstitialDidDismissScreen(ad: TTCAdInterstitial)
    
    /// Called just before the application will background or terminate because the user clicked on an
    /// ad that will launch another application (such as the App Store). The normal
    /// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
    /// before this.
    func interstitialWillLeaveApplication(ad: TTCAdInterstitial)
}
