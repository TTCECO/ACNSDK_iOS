//
//  ACNAdInterstitialViewController.swift
//  ACN_SDK_admob_Demo
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import ACNSDK

class InterstitialViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    var interstitial: ACNAdInterstitial!
    
    let timeLenght: Int = 5
    
    var timeLeft: Int = 5
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loadTap(_ sender: Any) {

        interstitial = ACNAdInterstitial(adUnitID: "ca-app-pub-3081086010287406/6838185997")
        interstitial.delegate = self
        let request = ACNAdRequest()
//        request.testDevices = [ACNkAdSimulatorID, "a6f4cc131cbe0effa815572262d24262"]
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

extension InterstitialViewController: ACNAdInterstitialDelegate {
    func interstitialDidReceiveAd(ad: ACNAdInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    func interstitialDidFailToReceiveAdWithError(ad: ACNAdInterstitial, error: Error) {
        print("interstitialDidFailToReceiveAdWithError")
    }
    
    func interstitialWillPresentScreen(ad: ACNAdInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    func interstitialDidFailToPresentScreen(ad: ACNAdInterstitial) {
        print("interstitialDidFailToPresentScreen")
    }
    
    func interstitialWillDismissScreen(ad: ACNAdInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    func interstitialDidDismissScreen(ad: ACNAdInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(ad: ACNAdInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
