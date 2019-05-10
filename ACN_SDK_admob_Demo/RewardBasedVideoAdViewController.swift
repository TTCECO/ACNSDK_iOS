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

    var rewardBasedVideo: ACNAdRewardBasedVideoAd!
    
    let timeLenght: Int = 5
    
    var timeLeft: Int = 5
    
    var timer: Timer?
    
    var adRequestInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardBasedVideo = ACNAdRewardBasedVideoAd.sharedInstance
        rewardBasedVideo.delegate = self
        
    }

    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTap(_ sender: Any) {
        
        if !adRequestInProgress {
            
            let request = ACNAdRequest()
//            request.testDevices = [ACNkAdSimulatorID, "a6f4cc131cbe0effa815572262d24262"]
            rewardBasedVideo.loadRequest(request: request, adUnitID: "ca-app-pub-3081086010287406/2909838839")
            
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

extension RewardBasedVideoAdViewController: ACNAdRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(rewardBasedVideoAd: ACNAdRewardBasedVideoAd, didRewardUserWithReward reward: ACNAdReward) {
        print("receve: \(reward.amount?.description ?? "null") \(reward.rewardType?.description ?? "what?")")
    }
    
    func rewardBasedVideoAd(rewardBasedVideoAd: ACNAdRewardBasedVideoAd, didFailToLoadWithError error: Error)  {
        adRequestInProgress = false
        print("didFailTo" + error.localizedDescription)
    }
    
    func rewardBasedVideoAdDidReceiveAd(rewardBasedVideoAd: ACNAdRewardBasedVideoAd) {
        adRequestInProgress = false
        print("DidReceiveAd")
    }
    
    func rewardBasedVideoAdDidOpen(rewardBasedVideoAd: ACNAdRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidOpen")
    }
    
    func rewardBasedVideoAdDidStartPlaying(rewardBasedVideoAd: ACNAdRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidStartPlaying")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(rewardBasedVideoAd: ACNAdRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidCompletePlaying")
    }
    
    func rewardBasedVideoAdDidClose(rewardBasedVideoAd: ACNAdRewardBasedVideoAd) {
        print("rewardBasedVideoAdDidClose")
    }
    
    func rewardBasedVideoAdWillLeaveApplication(rewardBasedVideoAd: ACNAdRewardBasedVideoAd) {
        print("rewardBasedVideoAdWillLeaveApplication")
    }
}
