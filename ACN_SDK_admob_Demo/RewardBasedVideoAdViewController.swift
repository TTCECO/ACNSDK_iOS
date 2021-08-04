//
//  RewardBasedVideoAdViewController.swift
//  ACN_SDK_admob_Demo
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import ACNSDK

class RewardBasedVideoAdViewController: UIViewController {

    var rewardBasedVideo: ACNAdRewardAd!
    
    let timeLenght: Int = 5
    
    var timeLeft: Int = 5
    
    var timer: Timer?
    
    var adRequestInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardBasedVideo = ACNAdRewardAd(adUnitID: "ca-app-pub-3081086010287406/2909838839")
        rewardBasedVideo.delegate = self
    }

    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTap(_ sender: Any) {
        
        if !adRequestInProgress {
            
            let request = ACNAdRequest()
            rewardBasedVideo.loadRequest(request: request)
            
            timeLeft = timeLenght
            button.setTitle("\(timeLeft)", for: .normal)
            button.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerLeft), userInfo: nil, repeats: true)
            adRequestInProgress = true
        }
    }
    
    @objc func timerLeft() {
        
        timeLeft -= 1
        button.setTitle("\(timeLeft)", for: .normal)
        
        if timeLeft == 0 {
            button.isEnabled = true
            button.setTitle("load", for: .normal)
            timer?.invalidate()
            timer = nil
            
            if rewardBasedVideo.isReady {
                rewardBasedVideo.present(rootViewController: self)
            }
        }
    }
}

extension RewardBasedVideoAdViewController: ACNAdRewardAdDelegate {
    
    func rewardAd(_: ACNAdRewardAd, didRewardUserWithReward reward: ACNAdReward) {
        print(#function)
    }
    
    func rewardAd(_: ACNAdRewardAd, didFailToLoadWithError error: Error) {
        print(#function)
    }
    
    func rewardAdDidReceiveAd(rewardAd: ACNAdRewardAd) {
        print(#function)
    }
    
    func rewardAdDidRecordImpression(rewardAd: ACNAdRewardAd) {
        print(#function)
    }
    
    func rewardAdDidClicked(rewardAd: ACNAdRewardAd) {
        print(#function)
    }
    
    func rewardAd(_: ACNAdRewardAd, didFailToPresentFullScreenContent error: Error) {
        print(#function)
    }
    
    func rewardAdDidPresentFullScreenContent(rewardAd: ACNAdRewardAd) {
        print(#function)
    }
    
    func rewardWillDismissFullScreenContent(rewardAd: ACNAdRewardAd) {
        print(#function)
    }
    
    func rewardAdDidDismissFullScreenContent(rewardAd: ACNAdRewardAd) {
        print(#function)
    }
}
