//
//  RewardBasedVideoAdViewController.swift
//  TTC_SDK_admob_Demo
//
//  Created by chenchao on 2019/1/3.
//  Copyright © 2019 tataufo. All rights reserved.
//

import UIKit
import TTCSDK

class RewardBasedVideoAdViewController: UIViewController {

    var rewardBasedVideo: TTCAdRewardBasedVideoAd!
    
    let timeLenght: Int = 5
    
    var timeLeft: Int = 5
    
    var timer: Timer?
    
    var adRequestInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardBasedVideo = TTCAdRewardBasedVideoAd.sharedInstance
        rewardBasedVideo.delegate = self
        
    }

    @IBOutlet weak var button: UIButton!
    @IBAction func buttonTap(_ sender: Any) {
        
        if !adRequestInProgress {
            
            let request = TTCAdRequest()
            request.testDevices = [TTCkAdSimulatorID, "90cd7779ad573d00217a76a411ee2ca6"]
            rewardBasedVideo.loadRequest(request: request, adUnitID: "ca-app-pub-3940256099942544/1712485313")
            
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

extension RewardBasedVideoAdViewController: TTCAdRewardBasedVideoAdDelegate {
    
    func rewardBasedVideoAd(rewardBasedVideoAd: TTCAdRewardBasedVideoAd, didRewardUserWithReward reward: TTCAdReward) {
        print("receve: \(reward.amount?.description ?? "null") \(reward.rewardType?.description ?? "what?")")
    }
    
    func rewardBasedVideoAd(rewardBasedVideoAd: TTCAdRewardBasedVideoAd, didFailToLoadWithError error: Error)  {
        adRequestInProgress = false
        print("didFailTo" + error.localizedDescription)
    }
    
    func rewardBasedVideoAdDidReceiveAd(rewardBasedVideoAd: TTCAdRewardBasedVideoAd) {
        adRequestInProgress = false
        print("DidReceiveAd")
    }
    
    func rewardBasedVideoAdDidOpen(rewardBasedVideoAd: TTCAdRewardBasedVideoAd) {
        
    }
    
    func rewardBasedVideoAdDidStartPlaying(rewardBasedVideoAd: TTCAdRewardBasedVideoAd) {
        
    }
    
    func rewardBasedVideoAdDidCompletePlaying(rewardBasedVideoAd: TTCAdRewardBasedVideoAd) {
        
    }
    
    func rewardBasedVideoAdDidClose(rewardBasedVideoAd: TTCAdRewardBasedVideoAd) {
        
    }
    
    func rewardBasedVideoAdWillLeaveApplication(rewardBasedVideoAd: TTCAdRewardBasedVideoAd) {
        
    }
}
