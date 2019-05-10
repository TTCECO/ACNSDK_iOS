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
        
        banner = ACNAdBanner(adSize: .LargeBanner)
        banner.rootViewController = self
        banner.delegate = self
        banner.adSizeDelegate = self
        banner.adUnitID = "ca-app-pub-3081086010287406/7452359703"
        view.addSubview(banner.bannerView)
        banner.bannerView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.bottom.equalTo(-34)
        }
    }
    
    @IBAction func loadClick(_ sender: Any) {
        let request = ACNAdRequest()
//        request.testDevices = [ACNkAdSimulatorID, "a6f4cc131cbe0effa815572262d24262"]
        banner.loadRequest(requset: request)
    }
}

extension BannerViewController: ACNAdBannerDelegate {
    
    func adViewDidReceiveAd(_ banner: ACNAdBanner) {
        print("adViewDidReceiveAd:"+Date().description)
    }
    
    func adViewDidFailToReceiveAd(banner: ACNAdBanner, error: Error) {
        print("adViewDidFailToReceiveAd")
    }
    
    func adViewWillPresentScreen(banner: ACNAdBanner) {
        print("adViewWillPresentScreen")
    }
    
    func adViewWillDismissScreen(banner: ACNAdBanner) {
        print("adViewWillDismissScreen")
    }
    
    func adViewDidDismissScreen(banner: ACNAdBanner) {
        print("adViewDidDismissScreen")
    }
    
    func adViewWillLeaveApplication(banner: ACNAdBanner) {
        print("adViewWillLeaveApplication")
    }
}

extension BannerViewController: ACNAdSizeDelegate {
    func adViewWillChangeAdSize(bannerView: ACNAdBanner, size: CGSize) {
        print("adViewWillChangeAdSize")
    }
}
