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
public class TTCAdBanner: NSObject {

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
    
    /// Required to set this banner view to a proper size. Never create your own GADAdSize directly. Use
    /// one of the predefined standard ad sizes (such as kGADAdSizeBanner), or create one using the
    /// GADAdSizeFromCGSize method. If not using mediation, then changing the adSize after an ad has
    /// been shown will cause a new request (for an ad of the new size) to be sent. If using mediation,
    /// then a new request may not be sent.
    @objc public var adSize: TTCAdSize {
        didSet {
            switch adSize {
            case .Banner:
                (bannerView as! GADBannerView).adSize = kGADAdSizeBanner
            case .LargeBanner:
                (bannerView as! GADBannerView).adSize = kGADAdSizeLargeBanner
            case .MediumRectangle:
                (bannerView as! GADBannerView).adSize = kGADAdSizeMediumRectangle
            case .FullBanner:
                (bannerView as! GADBannerView).adSize = kGADAdSizeFullBanner
            case .Leaderboard:
                (bannerView as! GADBannerView).adSize = kGADAdSizeLeaderboard
            case .Fluid:
                (bannerView as! GADBannerView).adSize = kGADAdSizeFluid
            default:
                (bannerView as! GADBannerView).adSize = kGADAdSizeBanner
            }
        }
    }
    
    /// Required reference to the root view controller for the banner view. This is the view controller
    /// the banner will present from if necessary (for example, presenting a landing page after a user
    /// click). Most commonly, this is the view controller the banner is displayed in.
    @objc public weak var rootViewController: UIViewController? {
        didSet {
            (bannerView as! GADBannerView).rootViewController = rootViewController
        }
    }
    
    /// A Boolean value that determines whether autoloading of ads in the receiver is enabled. If
    /// enabled, you do not need to call the loadRequest: method to load ads.
//    @objc public var isAutoloadEnabled: Bool {
//        didSet {
//            (bannerView as! GADBannerView).isAutoloadEnabled = isAutoloadEnabled
//        }
//    }
    
    /// Optional delegate object that receives state change notifications from this TTCBanner.
    /// Typically this is a UIViewController.
    @objc public weak var delegate: TTCAdBannerDelegate?
    
    /// Optional delegate that is notified when creatives cause the banner to change size.
    @objc public weak var adSizeDelegate: TTCAdSizeDelegate?
    
    fileprivate var tapCount: Int = 0
    
    // --------------------------------------
    
    /// init
    @objc public override init() {
//        isAutoloadEnabled = false
        adSize = .Banner
        super.init()
        
        bannerView = GADBannerView()
        (bannerView as! GADBannerView).delegate = self
        (bannerView as! GADBannerView).adSizeDelegate = self
    }
    
    /// init with asSize
    @objc public convenience init(adSize: TTCAdSize) {
        self.init(adSize: adSize, origin: CGPoint(x: 0, y: 0))
    }
    
    /// init with asSize and origin
    @objc public init(adSize: TTCAdSize, origin: CGPoint) {
//        isAutoloadEnabled = false
        self.adSize = adSize
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
        
        (bannerView as! GADBannerView).delegate = self
        (bannerView as! GADBannerView).adSizeDelegate = self
    }
}

//MARK: - load
extension TTCAdBanner: TTCAdLoadProtocol {
    
    /// Makes an ad request. The request object supplies targeting information.
    @objc public func loadRequest(requset: TTCAdRequest) {
        (bannerView as! GADBannerView).load(requset.gadRequest)
    }
    
}

//MARK: - GADBannerViewDelegate
extension TTCAdBanner: GADBannerViewDelegate {
    
    /// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
    /// the banner view to the view hierarchy if it hasn't been added yet.
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        tapCount = 0
        TTCAdupload.shared.upload(adUnitID: adUnitID ?? "", handleType: 1)
        self.delegate?.adViewDidReceiveAd?(self)
    }
    
    /// Tells the delegate that an ad request failed. The failure is normally due to network
    /// connectivity or ad availablility (i.e., no fill).
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        self.delegate?.adViewDidFailToReceiveAd?(banner: self, error: error)
    }
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        self.delegate?.adViewWillPresentScreen?(banner: self)
    }
    
    /// Tells the delegate that the full screen view will be dismissed.
    public func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        self.delegate?.adViewWillDismissScreen?(banner: self)
    }
    
    /// Tells the delegate that the full screen view has been dismissed. The delegate should restart
    /// anything paused while handling adViewWillPresentScreen:.
    public func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        self.delegate?.adViewDidDismissScreen?(banner: self)
    }
    
    /// Tells the delegate that the user click will open another app, backgrounding the current
    /// application. The standard UIApplicationDelegate methods, like applicationDidEnterBackground:,
    /// are called immediately before this method is called.
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        if tapCount >= 1 {
            return
        }
        tapCount += 1
        TTCAdupload.shared.upload(adUnitID: adUnitID ?? "", handleType: 2)
        self.delegate?.adViewWillLeaveApplication?(banner: self)
    }
}

//MARK: - GADAdSizeDelegate
extension TTCAdBanner: GADAdSizeDelegate {
    
    /// Called before the ad view changes to the new size.
    public func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        self.adSizeDelegate?.adViewWillChangeAdSize(bannerView: self, size: size.size)
    }
    
}
