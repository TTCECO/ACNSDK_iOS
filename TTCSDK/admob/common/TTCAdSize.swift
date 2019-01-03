//
//  TTCAdSize.swift
//  TTCSDK
//
//  Created by chenchao on 2018/12/29.
//  Copyright © 2018 tataufo. All rights reserved.
//

@objc public enum TTCAdSize: NSInteger {
    case Banner = 1                 /// iPhone and iPod Touch ad size. Typically 320x50.
    case LargeBanner = 2            /// Taller version of kTTCAdSizeBanner. Typically 320x100.
    case MediumRectangle = 3        /// Medium Rectangle size for the iPad (especially in a UISplitView's left pane). Typically 300x250.
    case FullBanner = 4             /// Full Banner size for the iPad (especially in a UIPopoverController or in                   /// UIModalPresentationFormSheet). Typically 468x60.
    case Leaderboard = 5            /// Leaderboard size for the iPad. Typically 728x90.
    case Fluid = 6                  /// An ad size that spans the full width of its container, with a height dynamically determined by  the ad.
}

@objc public protocol TTCAdSizeDelegate {
    
    /// Called before the ad view changes to the new size.
    func adViewWillChangeAdSize(bannerView: TTCAdBanner, size: CGSize)
}
