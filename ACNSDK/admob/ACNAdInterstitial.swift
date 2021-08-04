//
//  ACNInterstitial.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/2.
//  Copyright © 2019 tataufo. All rights reserved.
//

import GoogleMobileAds

@objc public class ACNAdInterstitial: NSObject {
    
    private var interstitial: GADInterstitialAd?
    private let adUnitID: String
    
    /// Optional delegate object that receives state change notifications from this GADInterstitalAd.
    @objc public weak var delegate: ACNAdInterstitialDelegate?
    
    /// Initializes an interstitial with an ad unit created on the AdMob website. Create a new ad unit
    /// for every unique placement of an ad in your application. Set this to the ID assigned for this
    /// placement. Ad units are important for targeting and statistics.
    ///
    /// Example AdMob ad unit ID: @"ca-app-pub-0123456789012345/0123456789"
    @objc public init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }
    
    @objc public var isReady: Bool = false
    
    /// Loads an interstitial ad.
    @objc public func loadRequest(requset: ACNAdRequest) {
        GADInterstitialAd.load(withAdUnitID: adUnitID,
                               request: requset.gadRequest) { ad, error in
            
            if let ad = ad {
                self.isReady = true
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                
                self.delegate?.interstitialDidReceiveAd?(ad: self)
                
            } else if let err = error {
                self.isReady = false
                self.delegate?.interstitial?(self, didFailToReceiveAdWithError: err)
            }
        }
    }
}

extension ACNAdInterstitial {
    
    /// Presents the interstitial ad. Must be called on the main thread.
    ///
    /// @param rootViewController A view controller to present the ad.
    @objc public func present(rootViewController: UIViewController) {
        interstitial?.present(fromRootViewController: rootViewController)
    }
}

extension ACNAdInterstitial: GADFullScreenContentDelegate {
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.interstitialDidRecordImpression?(ad: self)
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        ACNAdupload.upload(adUnitID: adUnitID, handleType: 2)
        self.delegate?.interstitialDidRecordClick?(ad: self)
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.delegate?.interstitial?(ad: self, didFailToPresentFullScreenContentWithError: error)
    }
    
    public func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        ACNAdupload.upload(adUnitID: adUnitID, handleType: 1)
        self.delegate?.interstitialDidPresentFullScreenContent?(ad: self)
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.interstitialWillDismissFullScreenContent?(ad: self)
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.interstitialDidDismissFullScreenContent?(ad: self)
    }
}
