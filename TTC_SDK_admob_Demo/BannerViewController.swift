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
        banner.rootViewController = self
        banner.delegate = self
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        banner.loadRequest()
        view.addSubview(banner.bannerView)
        
        banner.bannerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(-34)
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
