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

    var banner: TTCBanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        banner = TTCBanner(adSize: .LargeBanner)
        banner.rootViewController = self
        banner.delegate = self
        banner.adSizeDelegate = self
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        view.addSubview(banner.bannerView)
        banner.bannerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(-34)
        }
        
        banner.loadRequest(testDevices: ["90cd7779ad573d00217a76a411ee2ca6"])
    }
}

extension BannerViewController: TTCBannerDelegate {
    
    func adViewDidReceiveAd(_ banner: TTCBanner) {
        print("adViewDidReceiveAd")
    }
    
    func adViewDidFailToReceiveAd(banner: TTCBanner, error: Error) {
        print("adViewDidFailToReceiveAd")
    }
    
    func adViewWillPresentScreen(banner: TTCBanner) {
        print("adViewWillPresentScreen")
    }
    
    func adViewWillDismissScreen(banner: TTCBanner) {
        print("adViewWillDismissScreen")
    }
    
    func adViewDidDismissScreen(banner: TTCBanner) {
        print("adViewDidDismissScreen")
    }
    
    func adViewWillLeaveApplication(banner: TTCBanner) {
        print("adViewWillLeaveApplication")
    }
}

extension BannerViewController: TTCAdSizeDelegate {
    func adViewWillChangeAdSize(bannerView: TTCBanner, size: CGSize) {
        print("adViewWillChangeAdSize")
    }
}
