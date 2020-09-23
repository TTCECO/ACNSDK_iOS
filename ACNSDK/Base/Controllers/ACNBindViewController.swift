//
//  ACNBindViewController.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/3  下午8:03.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit
import ACN_SDK_NET

enum Language {
    case TTCWallet
    case Bind
    case Title
    
    func title(key: String, reward: Int = 0) -> String {
        
        if key == "zh" {
            switch self {
            case .TTCWallet:
                return "MARO Connect"
            case .Bind:
                return "绑定"
            case .Title:
                if reward == 0 {
                    return "绑定"
                }
                return "绑定后领取\(reward)MARO"
            }
        } else {
            switch self {
            case .TTCWallet:
                return "MARO Connect"
            case .Bind:
                return "Bind"
            case .Title:
                if reward == 0 {
                    return "Bind"
                }
                return "Receive \(reward)MARO after binding"
            }
        }
    }
}

fileprivate extension UIColor {
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

internal class ACNBindViewController: ACNViewController {
    
    let language: String
    
    let closeBtn = UIButton(frame: CGRect(x: 9, y: 19 + iPhoneXNavBarOffset, width: 44, height: 44))
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 22 + iPhoneXNavBarOffset, width: 50, height: 40))
    let walletIcon = ACNAppIcon()
    let appIcon = ACNAppIcon()
    let arrow = UIImageView(frame: CGRect(x: 170, y: 170, width: 36, height: 20))
    let bindBtn = UIButton(frame: CGRect(x: 20, y: 272, width: 335, height: 34))
    
    init(language: String) {
        self.language = language
        super.init(nibName: nil, bundle: nil)
        
        setupSubviews()
    }
    
    func setupSubviews() {
        
        view.addSubview(closeBtn)
        view.addSubview(titleLabel)
        view.addSubview(walletIcon)
        view.addSubview(arrow)
        view.addSubview(appIcon)
        view.addSubview(bindBtn)
        
        closeBtn.setTitleColor(UIColor.black, for: .normal)
        closeBtn.setImage(UIImage.ACNImg(name: "close_normal"), for: .normal)
        closeBtn.setImage(UIImage.ACNImg(name: "close_highlighted"), for: .highlighted)
        closeBtn.addTarget(self, action: #selector(closeBtnClick(_:)), for: .touchUpInside)
        
        titleLabel.textAlignment = .center
        titleLabel.text = Language.Title.title(key: language, reward: ACNManager.shared.reward)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 43/255.0, green: 46/255.0, blue: 61/255.0, alpha: 1)
        
        if ACNManager.shared.walletBindType == 1 {
            walletIcon.setAppiconAndTitle(icon: UIImage.ACNImg(name: "ACNWallet"), title: "")
        } else {
            walletIcon.setAppiconAndTitle(icon: UIImage.ACNImg(name: "TTCWallet"), title: "")
        }
        
//        var appName = ""
//        let info = Bundle.main.infoDictionary
//        if info != nil, ((info!["CFBundleDisplayName"] as? String) != nil) {
//            appName = info!["CFBundleDisplayName"] as! String
//        }
        //NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
        var dappIcon = UIImage(named: "AppIcon60x60")
        if dappIcon == nil {
            dappIcon = UIImage(named: "AppIcon")
        }
        
        appIcon.setAppiconAndTitle(icon: dappIcon, title: "")
        arrow.image = UIImage.ACNImg(name: "+++")
        
        bindBtn.setTitle(Language.Bind.title(key: language), for: .normal)
        bindBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        bindBtn.setTitleColor(UIColor(hex: "15E981"), for: .normal)
        bindBtn.layer.cornerRadius = 6
        bindBtn.backgroundColor = UIColor(hex: "2E3233")
        bindBtn.layer.shadowColor = UIColor(hex: "2E3233").cgColor
        bindBtn.layer.shadowOpacity = 0.3
        bindBtn.layer.shadowOffset = CGSize(width: 2, height: 2)
        bindBtn.addTarget(self, action: #selector(bindBtnClick(_:)), for: .touchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let x = self.view.bounds.size.width
        let y = self.view.bounds.size.height
        
        bindBtn.frame = CGRect(x: 20, y: y - 44 - 20 - iPhoneXBottomOffset, width: x - 40, height:44)
        
        let width = titleLabel.text!.textWidth(font: titleLabel.font)
        titleLabel.frame = CGRect(x: 20.0, y: 40+64+iPhoneXNavBarOffset, width: width, height: 40)
        appIcon.frame = CGRect(origin: CGPoint(x: (x-appIcon.frame.width)/2, y: titleLabel.frame.origin.y+100), size: appIcon.frame.size)
        arrow.frame = CGRect(origin: CGPoint(x: (x-60)/2, y: appIcon.frame.origin.y+appIcon.frame.height+72), size: CGSize(width: 60, height: 64))
        walletIcon.frame = CGRect(origin: CGPoint(x: (x-walletIcon.frame.width)/2, y: arrow.frame.origin.y+arrow.frame.height+72), size: walletIcon.frame.size)
    }

    @objc private func bindBtnClick(_ sender: UIButton) {

        sender.isEnabled = false
        ACNNetworkManager.bindingDapp(isBind: true, walletAddress: ACNManager.shared.walletAddress!) { (success, error, info) in
            sender.isEnabled = true
            
            if success, let bindInfo = info {
                ACNManager.shared.userInfo?.wallet = ACNManager.shared.walletAddress
                ACNPrint("bind - Bind successfully, address: \(ACNManager.shared.walletAddress!)")
                ACNManager.shared.backWallet(bindState: 1, reward: bindInfo.reward, symbol: bindInfo.symbol)
                self.dismiss(animated: true, completion: nil)
            } else {
                ACNPrint("bind - Bind failed: \(String(describing: error?.errorDescription))")
                ACNManager.shared.backWallet(bindState: 0, reward: 0, symbol: "")
                self.dismiss(animated: true, completion: nil)
            }

        }
    }
    
    @objc private func importBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func closeBtnClick(_ sender: UIButton) {
        
        ACNManager.shared.backWallet(bindState: -1, reward: 0, symbol: "")
        self.dismiss(animated: true, completion: nil)
    }
}
