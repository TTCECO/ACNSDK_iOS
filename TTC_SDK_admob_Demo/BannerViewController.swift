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
    
    var banner: TTCAdBanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        banner = TTCAdBanner(adSize: .LargeBanner)
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
        let request = TTCAdRequest()
//        request.testDevices = [TTCkAdSimulatorID, "a6f4cc131cbe0effa815572262d24262"]
        banner.loadRequest(requset: request)
    }
}

extension BannerViewController: TTCAdBannerDelegate {
    
    func adViewDidReceiveAd(_ banner: TTCAdBanner) {
        print("adViewDidReceiveAd:"+Date().description)
    }
    
    func adViewDidFailToReceiveAd(banner: TTCAdBanner, error: Error) {
        print("adViewDidFailToReceiveAd")
    }
    
    func adViewWillPresentScreen(banner: TTCAdBanner) {
        print("adViewWillPresentScreen")
    }
    
    func adViewWillDismissScreen(banner: TTCAdBanner) {
        print("adViewWillDismissScreen")
    }
    
    func adViewDidDismissScreen(banner: TTCAdBanner) {
        print("adViewDidDismissScreen")
    }
    
    func adViewWillLeaveApplication(banner: TTCAdBanner) {
        print("adViewWillLeaveApplication")
    }
}

extension BannerViewController: TTCAdSizeDelegate {
    func adViewWillChangeAdSize(bannerView: TTCAdBanner, size: CGSize) {
        print("adViewWillChangeAdSize")
    }
}
