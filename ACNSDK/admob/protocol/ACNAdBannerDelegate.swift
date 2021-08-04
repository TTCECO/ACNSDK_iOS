//
//  ACNBannerDelegate.swift
//  ACNSDK
//
//  Created by chenchao on 2018/12/29.
//  Copyright © 2018 tataufo. All rights reserved.
//

@objc public protocol ACNAdBannerDelegate {
 
    //MARK: - Ad Request Lifecycle Notifications
    
    /// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
    /// the banner view to the view hierarchy if it hasn't been added yet.
    @objc optional func bannerViewDidReceiveAd(_ banner: ACNAdBanner)
    
    /// Tells the delegate that an ad request failed. The failure is normally due to network
    /// connectivity or ad availablility (i.e., no fill).
    @objc optional func bannerView(_ banner: ACNAdBanner, didFailToReceiveAdWithError error: Error)
    
    /// Tells the delegate that an impression has been recorded for an ad.
    @objc optional func bannerViewDidRecordImpression(banner: ACNAdBanner)
    
    /// Tells the delegate that a click has been recorded for the ad.
    @objc optional func bannerViewDidRecordClick(banner: ACNAdBanner)
    
    //MARK: - Click-Time Lifecycle Notifications
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    @objc optional func bannerViewWillPresentScreen(banner: ACNAdBanner)
    
    /// Tells the delegate that the full screen view will be dismissed.
    @objc optional func bannerViewWillDismissScreen(banner: ACNAdBanner)
    
    /// Tells the delegate that the full screen view has been dismissed. The delegate should restart
    /// anything paused while handling bannerViewWillPresentScreen:.
    @objc optional func bannerViewDidDismissScreen(banner: ACNAdBanner)
    

}

