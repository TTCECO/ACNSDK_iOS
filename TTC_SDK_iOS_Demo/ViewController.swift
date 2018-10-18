//
//  ViewController.swift
//  TTC_SDK_iOS_Demo
// 
//  Created by Zhang Yufei on 2018/7/2  下午4:07.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit
import TTCSDK

class ViewController: UIViewController {
    
    let dataArr = ["Login", "Logout", "Update", "Querry account balance", "Querry wallet balance", "Unbind", "Upload", "open/close SDK"]
    var itemSize: CGSize?
    var enabled: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.white
        itemSize = CGSize(width: (view.bounds.size.width - 4) / 3.0, height: (view.bounds.size.width - 4) / 3.0)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var collectionView: UICollectionView!
    func setupSubviews() {

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.register(TTCActionCell.self, forCellWithReuseIdentifier: "CollectionViewCellID")
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        collectionView.frame = view.bounds
    }
    
    func queryAccountBalance() {
        TTCSDK.queryAccountBalance { (success, error, balance) in

            if success {
                TWToast.showToast(text: "account balance: \(balance)")
            } else {
                TWToast.showToast(text: "error: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    func queryWalletBalance() {
        TTCSDK.queryWalletBalance { (success, error, balance) in
            if success {
                TWToast.showToast(text: "wallet balance: \(balance)")
            } else {
                TWToast.showToast(text: "error: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    func unBindWallet() {
        TTCSDK.unBindWallet { (success, error) in
            if success {
                TWToast.showToast(text: "unbind success")
            } else {
                TWToast.showToast(text: "error: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    func uploadAction() {
        guard let userid = TTCUser.shared.userId, !userid.isEmpty else { return TWToast.showToast(text: "login first") }

        let vc = TTCUploadViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func login() {
        let user = TTCUserInfo(userId: "12345")
        TTCSDK.login(userInfo: user) { (success, error, _) -> Void in
            
            if success {
                TWToast.showToast(text: "login success")
                TTCUser.shared.userId = user.userId
            } else {
                print(String(describing: error?.errorDescription))
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellID", for: indexPath) as! TTCActionCell
        
        cell.setTitle(title: dataArr[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return itemSize!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.item {
        case 0:
            if TTCUser.shared.userId == nil || TTCUser.shared.userId!.isEmpty {
                
                print(dataArr[0])
                let login = TTCLoginViewController()
                self.present(login, animated: true, completion: nil)
                //            login()
            } else {
                TWToast.showToast(text: "Already login")
            }
        case 1:
            print(dataArr[1])
            TTCSDK.logout()
            TTCUser.shared.userId = nil
            TWToast.showToast(text: "logout")
        case 2:
            if TTCUser.shared.userId == nil || TTCUser.shared.userId!.isEmpty {
                TWToast.showToast(text: "login first in the update information")
            } else {
                print(dataArr[2])
                let login = TTCLoginViewController()
                login.isLogin = false
                self.present(login, animated: true, completion: nil)
            }
        case 3:
            print(dataArr[3])
            queryAccountBalance()
        case 4:
            print(dataArr[4])
            queryWalletBalance()
        case 5:
            print(dataArr[5])
            unBindWallet()
        case 6:
            print(dataArr[6])
            uploadAction()
        case 7:
            enabled = !enabled
            TTCSDK.sdk(isEnabled: enabled)
            TWToast.showToast(text: "SDK state \(enabled)")
        default: break
        }
    }
}
