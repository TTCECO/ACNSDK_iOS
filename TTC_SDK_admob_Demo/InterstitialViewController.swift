//
//  TTCAdInterstitialViewController.swift
//  TTC_SDK_admob_Demo
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import TTCSDK

class InterstitialViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    var interstitial: TTCAdInterstitial!
    
    let timeLenght: Int = 5
    
    var timeLeft: Int = 5
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loadTap(_ sender: Any) {

        interstitial = TTCAdInterstitial(adUnitID: "ca-app-pub-3081086010287406/6838185997")
        interstitial.delegate = self
        let request = TTCAdRequest()
//        request.testDevices = [TTCkAdSimulatorID, "a6f4cc131cbe0effa815572262d24262"]
        interstitial.loadRequest(requset: request)
        
        timeLeft = timeLenght
        button.setTitle("\(timeLeft)", for: .normal)
        button.isEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerLeft), userInfo: nil, repeats: true)
    }
    
    @objc func timerLeft() {
        
        timeLeft -= 1
        button.setTitle("\(timeLeft)", for: .normal)
        
        if timeLeft == 0 {
            button.isEnabled = true
            button.setTitle("load", for: .normal)
            timer?.invalidate()
            timer = nil
            
            if interstitial.isReady {
                interstitial.present(rootViewController: self)
            }
        }
    }
}

extension InterstitialViewController: TTCAdInterstitialDelegate {
    func interstitialDidReceiveAd(ad: TTCAdInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    func interstitialDidFailToReceiveAdWithError(ad: TTCAdInterstitial, error: Error) {
        print("interstitialDidFailToReceiveAdWithError")
    }
    
    func interstitialWillPresentScreen(ad: TTCAdInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    func interstitialDidFailToPresentScreen(ad: TTCAdInterstitial) {
        print("interstitialDidFailToPresentScreen")
    }
    
    func interstitialWillDismissScreen(ad: TTCAdInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    func interstitialDidDismissScreen(ad: TTCAdInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(ad: TTCAdInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
