//
//  TTCInterstitial.swift
//  TTCSDK
//
//  Created by chenchao on 2019/1/2.
//  Copyright © 2019 tataufo. All rights reserved.
//

import GoogleMobileAds
import TTC_SDK_NET

@objc public class TTCAdInterstitial: NSObject {

    var interstitial: GADInterstitial!
    
    /// Initializes an interstitial with an ad unit created on the AdMob website. Create a new ad unit
    /// for every unique placement of an ad in your application. Set this to the ID assigned for this
    /// placement. Ad units are important for targeting and statistics.
    ///
    /// Example AdMob ad unit ID: @"ca-app-pub-0123456789012345/0123456789"
    @objc public init(adUnitID: String) {
        super.init()
        interstitial = GADInterstitial(adUnitID: adUnitID)
        interstitial.delegate = self
    }
    
    /// Required value created on the TTCAdMob website. Create a new ad unit for every unique placement of
    /// an ad in your application. Set this to the ID assigned for this placement. Ad units are
    /// important for targeting and statistics.
    ///
    /// Example AdMob ad unit ID: @"ca-app-pub-0123456789012345/0123456789"
    @objc public var adUnitID: String? {
        get {
           return interstitial.adUnitID
        }
    }
    
    /// Optional delegate object that receives state change notifications from this GADInterstitalAd.
    @objc public weak var delegate: TTCAdInterstitialDelegate?
    
    /// Returns YES if the interstitial is ready to be displayed. The delegate's
    /// interstitialAdDidReceiveAd: will be called after this property switches from NO to YES.
    @objc public var isReady: Bool {
        get {
            return interstitial.isReady
        }
    }
    
    /// Returns YES if this object has already been presented. Interstitial objects can only be used
    /// once even with different requests.
    @objc public var hasBeenUsed: Bool {
        get {
            return interstitial.hasBeenUsed
        }
    }
}

extension TTCAdInterstitial {
    
    /// Presents the interstitial ad which takes over the entire screen until the user dismisses it.
    /// This has no effect unless isReady returns YES and/or the delegate's interstitialDidReceiveAd:
    /// has been received.
    ///
    /// Set rootViewController to the current view controller at the time this method is called. If your
    /// application does not use view controllers pass in nil and your views will be removed from the
    /// window to show the interstitial and restored when done. After the interstitial has been removed,
    /// the delegate's interstitialDidDismissScreen: will be called.
    @objc public func present(rootViewController: UIViewController) {
        interstitial.present(fromRootViewController: rootViewController)
    }
}

extension TTCAdInterstitial: TTCAdLoadProtocol {
    
    /// Makes an interstitial ad request. Additional targeting options can be supplied with a request
    /// object. Only one interstitial request is allowed at a time.
    ///
    /// This is best to do several seconds before the interstitial is needed to preload its content.
    /// Then when transitioning between view controllers show the interstital with
    /// presentFromViewController.
    @objc public func loadRequest(requset: TTCAdRequest) {
        interstitial.load(requset.gadRequest)
    }
}

extension TTCAdInterstitial: GADInterstitialDelegate {

    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        self.delegate?.interstitialDidReceiveAd?(ad: self)
    }
    
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        self.delegate?.interstitialDidReceiveAd?(ad: self)
    }
    
    public func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        TTCAdupload.shared.upload(adUnitID: adUnitID ?? "", handleType: 1)
        self.delegate?.interstitialWillPresentScreen?(ad: self)
    }
    
    public func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        self.delegate?.interstitialDidFailToPresentScreen?(ad: self)
    }
    
    public func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.delegate?.interstitialWillDismissScreen?(ad: self)
    }
    
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.delegate?.interstitialDidDismissScreen?(ad: self)
    }
    
    public func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        TTCAdupload.shared.upload(adUnitID: adUnitID ?? "", handleType: 2)
        self.delegate?.interstitialWillLeaveApplication?(ad: self)
    }
}
