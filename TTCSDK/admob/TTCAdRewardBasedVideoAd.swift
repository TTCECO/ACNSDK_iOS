//
//  TTCAdRewardBasedVideoAd.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import GoogleMobileAds

@objc public class TTCAdRewardBasedVideoAd: NSObject {

    /// Returns the shared TTCAdRewardBasedVideoAd instance.
    @objc public static let sharedInstance: TTCAdRewardBasedVideoAd = TTCAdRewardBasedVideoAd()
    
    var rewardBasedVideo: GADRewardBasedVideoAd = GADRewardBasedVideoAd.sharedInstance()
    var adUnitID: String?
    
    override init() {
        super.init()
        rewardBasedVideo.delegate = self
    }
    
    /// Delegate for receiving video notifications.
    @objc public weak var delegate: TTCAdRewardBasedVideoAdDelegate?
    
    /// Indicates if the receiver is ready to be presented full screen.
    @objc public var isReady: Bool {
        get {
            return rewardBasedVideo.isReady
        }
    }
    
    /// A unique identifier used to identify the user when making server-to-server reward callbacks.
    /// This value is used at both request time and during ad display. New values must only be set
    /// before ad requests.
    @objc public var userIdentifier: String? {
        didSet {
            rewardBasedVideo.userIdentifier = userIdentifier
        }
    }
    
    /// Optional custom reward string to include in the server-to-server callback.
    @objc public var customRewardString: String? {
        didSet {
            rewardBasedVideo.customRewardString = customRewardString
        }
    }
    
}

extension TTCAdRewardBasedVideoAd {
    
    /// Initiates the request to fetch the reward based video ad. The |request| object supplies ad
    /// targeting information and must not be nil. The adUnitID is the ad unit id used for fetching an
    /// ad and must not be nil.
    @objc public func loadRequest(request: TTCAdRequest, adUnitID: String) {
        self.adUnitID = adUnitID
        rewardBasedVideo.load(request.gadRequest, withAdUnitID: adUnitID)
    }
}

extension TTCAdRewardBasedVideoAd {
    
    /// Presents the reward based video ad with the provided view controller.
    @objc public func present(rootViewController: UIViewController) {
        rewardBasedVideo.present(fromRootViewController: rootViewController)
    }
}

extension TTCAdRewardBasedVideoAd: GADRewardBasedVideoAdDelegate {
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        TTCAdupload.shared.upload(adUnitID: adUnitID ?? "", handleType: 3)
        self.delegate?.rewardBasedVideoAd(rewardBasedVideoAd: self, didRewardUserWithReward: TTCAdReward(reward: reward))
    }
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        self.delegate?.rewardBasedVideoAd?(rewardBasedVideoAd: self, didFailToLoadWithError: error)
    }
    
    public func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.delegate?.rewardBasedVideoAdDidReceiveAd?(rewardBasedVideoAd: self)
    }
    
    public func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        TTCAdupload.shared.upload(adUnitID: adUnitID ?? "", handleType: 1)
        self.delegate?.rewardBasedVideoAdDidOpen?(rewardBasedVideoAd: self)
    }
    
    public func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.delegate?.rewardBasedVideoAdDidStartPlaying?(rewardBasedVideoAd: self)
    }
    
    public func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.delegate?.rewardBasedVideoAdDidCompletePlaying?(rewardBasedVideoAd: self)
    }
    
    public func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.delegate?.rewardBasedVideoAdDidClose?(rewardBasedVideoAd: self)
    }
    
    public func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.delegate?.rewardBasedVideoAdWillLeaveApplication?(rewardBasedVideoAd: self)
    }
}
