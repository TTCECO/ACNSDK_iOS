//
//  ACNBannerView.swift
//  ACNSDK
//
//  Created by chenchao on 2018/12/29.
//  Copyright © 2018 tataufo. All rights reserved.
//

import UIKit
import GoogleMobileAds

/// The view that displays banner ads. A minimum implementation to get an ad from within a
/// UIViewController class is:
public class ACNAdBanner: NSObject {

    @objc public var bannerView: UIView!
    
    /// Optional delegate object that receives state change notifications from this ACNBanner.
    /// Typically this is a UIViewController.
    @objc public weak var delegate: ACNAdBannerDelegate?
    
    /// Optional delegate that is notified when creatives cause the banner to change size.
    @objc public weak var adSizeDelegate: ACNAdSizeDelegate?
    
    private var tapCount: Int = 0
    private let adUnitID: String
    
    /// Init with adSize, adUnitID, rootViewController
    /// - Parameters:
    ///   - adSize: banner view size
    ///   - adUnitID: Example AdMob ad unit ID: @"ca-app-pub-0123456789012345/0123456789"
    ///   - rootViewController: Required reference to a root view controller that is used by the banner to present full screen content after the user interacts with the ad. The root view controller is most commonly the view controller displaying the banner.
    @objc public init(adSize: ACNAdSize,
                      adUnitID: String,
                      rootViewController: UIViewController) {
        self.adUnitID = adUnitID
        super.init()
        
        switch adSize {
        case .Banner:
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        case .LargeBanner:
            bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        case .MediumRectangle:
            bannerView = GADBannerView(adSize: kGADAdSizeMediumRectangle)
        case .FullBanner:
            bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
        case .Leaderboard:
            bannerView = GADBannerView(adSize: kGADAdSizeLeaderboard)
        case .Fluid:
            bannerView = GADBannerView(adSize: kGADAdSizeFluid)
        default:
            bannerView = GADBannerView()
        }
        (bannerView as! GADBannerView).adUnitID = adUnitID
        (bannerView as! GADBannerView).delegate = self
        (bannerView as! GADBannerView).adSizeDelegate = self
        (bannerView as! GADBannerView).rootViewController = rootViewController
    }
}

//MARK: - load
extension ACNAdBanner: ACNAdLoadProtocol {
    
    /// Makes an ad request. The request object supplies targeting information.
    @objc public func loadRequest(requset: ACNAdRequest) {
        (bannerView as! GADBannerView).load(requset.gadRequest)
    }
    
}

//MARK: - GADBannerViewDelegate
extension ACNAdBanner: GADBannerViewDelegate {
    
    /// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
    /// the banner view to the view hierarchy if it hasn't been added yet.
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        tapCount = 0
        ACNAdupload.upload(adUnitID: adUnitID, handleType: 1)
        self.delegate?.bannerViewDidReceiveAd?(self)
    }
    
    /// Tells the delegate that an ad request failed. The failure is normally due to network
    /// connectivity or ad availablility (i.e., no fill).
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        
        self.delegate?.bannerView?(self, didFailToReceiveAdWithError: error)
    }
    
    /// Tells the delegate that an impression has been recorded for an ad.
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        self.delegate?.bannerViewDidRecordImpression?(banner: self)
    }
    
    /// Tells the delegate that a click has been recorded for the ad.
    public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        if tapCount >= 1 {
            return
        }
        tapCount += 1
        ACNAdupload.upload(adUnitID: adUnitID, handleType: 2)
        self.delegate?.bannerViewDidRecordClick?(banner: self)
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        
        self.delegate?.bannerViewWillPresentScreen?(banner: self)
    }
    
    /// Tells the delegate that the full screen view will be dismissed.
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        
        self.delegate?.bannerViewWillDismissScreen?(banner: self)
    }
    
    /// Tells the delegate that the full screen view has been dismissed. The delegate should restart
    /// anything paused while handling bannerViewWillPresentScreen:.
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        self.delegate?.bannerViewDidDismissScreen?(banner: self)
    }
}

//MARK: - GADAdSizeDelegate
extension ACNAdBanner: GADAdSizeDelegate {
    
    /// Called before the ad view changes to the new size.
    public func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        self.adSizeDelegate?.adViewWillChangeAdSize(bannerView: self, size: size.size)
    }
    
}
