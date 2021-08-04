//
//  ACNAdRewardAd.swift
//  ACNSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import GoogleMobileAds

@objc public class ACNAdRewardAd: NSObject {
    
    private var rewardAD: GADRewardedAd?
    private let adUnitID: String
    
    /// Delegate for receiving video notifications.
    @objc public weak var delegate: ACNAdRewardAdDelegate?
    
    @objc public init(adUnitID: String) {
        self.adUnitID = adUnitID
        
        super.init()
    }
    
    @objc public var isReady: Bool = false
    
    /// Initiates the request to fetch the reward based video ad. The |request| object supplies ad
    /// targeting information and must not be nil. The adUnitID is the ad unit id used for fetching an
    /// ad and must not be nil.
    @objc public func loadRequest(request: ACNAdRequest) {
        GADRewardedAd.load(withAdUnitID: adUnitID,
                           request: request.gadRequest) { ad, error in
            
            if let ad = ad {
                
                self.isReady = true
                self.rewardAD = ad
                self.rewardAD?.fullScreenContentDelegate = self
                self.delegate?.rewardAdDidReceiveAd?(rewardAd: self)
                
            } else if let err = error {
                
                self.isReady = false
                self.delegate?.rewardAd?(self, didFailToLoadWithError: err)
            }
        }
    }
}

extension ACNAdRewardAd {
    
    /// Presents the reward based video ad with the provided view controller.
    @objc public func present(rootViewController: UIViewController) {
        self.rewardAD?.present(fromRootViewController: rootViewController, userDidEarnRewardHandler: {
            if let reward = self.rewardAD?.adReward {
                ACNAdupload.upload(adUnitID: self.adUnitID, handleType: 3)
                self.delegate?.rewardAd?(self, didRewardUserWithReward: ACNAdReward(reward: reward))
            }
        })
    }
}

extension ACNAdRewardAd: GADFullScreenContentDelegate {
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.rewardAdDidRecordImpression?(rewardAd: self)
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.rewardAdDidClicked?(rewardAd: self)
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.delegate?.rewardAd?(self, didFailToPresentFullScreenContent: error)
    }
    
    public func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.rewardAdDidPresentFullScreenContent?(rewardAd: self)
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.rewardWillDismissFullScreenContent?(rewardAd: self)
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.rewardAdDidDismissFullScreenContent?(rewardAd: self)
    }
}
