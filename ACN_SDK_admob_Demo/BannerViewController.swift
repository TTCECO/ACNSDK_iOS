//
//  ViewController.swift
//  ACN_SDK_admob_Demo
//
//  Created by chenchao on 2018/12/29.
//  Copyright © 2018 tataufo. All rights reserved.
//

import UIKit
import ACNSDK
import SnapKit

class BannerViewController: UIViewController {
    
    var banner: ACNAdBanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        banner = ACNAdBanner(adSize: .LargeBanner, adUnitID: "ca-app-pub-3081086010287406/7452359703", rootViewController: self)
        banner.delegate = self
        banner.adSizeDelegate = self

        view.addSubview(banner.bannerView)
        banner.bannerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(-34)
        }
    }
    
    @IBAction func loadClick(_ sender: Any) {
        let request = ACNAdRequest()
        banner.loadRequest(requset: request)
    }
}

extension BannerViewController: ACNAdBannerDelegate {
    
    func bannerViewDidReceiveAd(_ banner: ACNAdBanner) {
        print(#function)
    }

    func bannerView(_ banner: ACNAdBanner, didFailToReceiveAdWithError error: Error) {
        print(#function)
    }
    
    func bannerViewDidRecordImpression(banner: ACNAdBanner) {
        print(#function)
    }

    func bannerViewDidRecordClick(banner: ACNAdBanner) {
        print(#function)
    }
    
    func bannerViewWillPresentScreen(banner: ACNAdBanner) {
        print(#function)
    }
    
    func bannerViewWillDismissScreen(banner: ACNAdBanner) {
        print(#function)
    }
    
    func bannerViewDidDismissScreen(banner: ACNAdBanner) {
        print(#function)
    }
    
}

extension BannerViewController: ACNAdSizeDelegate {
    func adViewWillChangeAdSize(bannerView: ACNAdBanner, size: CGSize) {
        print("adViewWillChangeAdSize")
    }
}
