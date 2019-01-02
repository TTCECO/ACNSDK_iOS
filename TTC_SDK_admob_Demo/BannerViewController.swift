//
//  ViewController.swift
//  TTC_SDK_admob_Demo
//
//  Created by chenchao on 2018/12/29.
//  Copyright © 2018 tataufo. All rights reserved.
//

import UIKit
import TTCSDK
import SnapKit

class BannerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let banner = TTCBanner(adSize: .LargeBanner)
//        let banner = TTCBanner()
        banner.rootViewController = self
        banner.delegate = self
        banner.adSizeDelegate = self
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        banner.loadRequest()
        banner.isAutoloadEnabled = true
        view.addSubview(banner.bannerView)
        
        banner.bannerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(-34)
//            make.width.equalTo(320)
//            make.height.equalTo(100)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
//            banner.bannerView.snp.makeConstraints({ (make) in
//                make.height.equalTo(200)
//            })
            banner.adSize = .Banner
        }
        
    }
}

extension BannerViewController: TTCBannerDelegate {
    
    func adViewDidReceiveAd(_ banner: TTCBanner) {
        
    }
    
    func adViewDidFailToReceiveAd(banner: TTCBanner, error: Error) {
        
    }
    
    func adViewWillPresentScreen(banner: TTCBanner) {
        
    }
    
    func adViewWillDismissScreen(banner: TTCBanner) {
        
    }
    
    func adViewDidDismissScreen(banner: TTCBanner) {
        
    }
    
    func adViewWillLeaveApplication(banner: TTCBanner) {
        
    }
}

extension BannerViewController: TTCAdSizeDelegate {
    func adViewWillChangeAdSize(bannerView: TTCBanner, size: CGSize) {
        
    }
}
