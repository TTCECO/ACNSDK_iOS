//
//  TTCBannerView.swift
//  TTCSDK
//
//  Created by chenchao on 2018/12/29.
//  Copyright © 2018 tataufo. All rights reserved.
//

import UIKit
import GoogleMobileAds

/// The view that displays banner ads. A minimum implementation to get an ad from within a
/// UIViewController class is:
public class TTCBanner: NSObject {

    @objc public var bannerView: UIView!
    
    /// Required value created on the TTCAdMob website. Create a new ad unit for every unique placement of
    /// an ad in your application. Set this to the ID assigned for this placement. Ad units are
    /// important for targeting and statistics.
    ///
    /// Example AdMob ad unit ID: @"ca-app-pub-0123456789012345/0123456789"
    @objc public var adUnitID: String? {
        didSet {
            (bannerView as! GADBannerView).adUnitID = adUnitID
        }
    }
    
    /// Required reference to the root view controller for the banner view. This is the view controller
    /// the banner will present from if necessary (for example, presenting a landing page after a user
    /// click). Most commonly, this is the view controller the banner is displayed in.
    @objc public var rootViewController: UIViewController? {
        didSet {
            (bannerView as! GADBannerView).rootViewController = rootViewController
        }
    }
    
    /// Optional delegate object that receives state change notifications from this TTCBanner.
    /// Typically this is a UIViewController.
    @objc public var delegate: TTCBannerDelegate? {
        didSet {
            (bannerView as! GADBannerView).delegate = self
        }
    }
    
    /// Optional delegate that is notified when creatives cause the banner to change size.
    @objc public var adSizeDelegate: TTCAdSizeDelegate? {
        didSet {
            (bannerView as! GADBannerView).adSizeDelegate = self
        }
    }
    
    @objc public override init() {
        bannerView = GADBannerView()
    }
    
    @objc public convenience init(adSize: TTCAdSize) {
        self.init(adSize: adSize, origin: CGPoint(x: 0, y: 0))
    }
    
    @objc public init(adSize: TTCAdSize, origin: CGPoint) {
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
    }
}

//MARK: - load
extension TTCBanner {
    
    /// Makes an ad request. The request object supplies targeting information.
    @objc public func loadRequest() {
        let request = GADRequest()
        (bannerView as! GADBannerView).load(request)
    }
    
    /// Makes an ad request. The request object supplies targeting information.
    /// Test ads will be returned for devices with device IDs specified in this array.
    @objc public func loadRequest(testDevuces: NSArray) {
        let request = GADRequest()
        request.testDevices = testDevuces as? [Any]
        (bannerView as! GADBannerView).load(request)
    }
}

//MARK: - GADBannerViewDelegate
extension TTCBanner: GADBannerViewDelegate {
    
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.delegate?.adViewDidReceiveAd(self)
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        self.delegate?.adViewDidFailToReceiveAd(banner: self, error: error)
    }
    
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        self.delegate?.adViewWillPresentScreen(banner: self)
    }
    
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        self.delegate?.adViewWillDismissScreen(banner: self)
    }
    
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        self.delegate?.adViewDidDismissScreen(banner: self)
    }
    
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        self.delegate?.adViewWillLeaveApplication(banner: self)
    }
}

//MARK: - GADAdSizeDelegate
extension TTCBanner: GADAdSizeDelegate {
    
    public func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        self.adSizeDelegate?.adViewWillChangeAdSize(bannerView: self, size: size.size)
    }
    
}
