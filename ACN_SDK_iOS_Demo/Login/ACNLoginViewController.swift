//
//  ACNLoginViewController.swift
//  ACN_SDK_iOS_Demo
//
//  Created by Zhang Yufei on 2018/7/17  下午6:15.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import UIKit
import ACNSDK

class ACNLoginViewController: UIViewController {
    
    var isLogin: Bool = true
    let login = UIButton(frame: CGRect(x: 0, y: 50, width: 200, height: 44))
    let tableview = UITableView(frame: CGRect(x: 0, y: 0, width: 375, height: 667), style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        initDataArr()

        tableview.backgroundColor = UIColor.white
        tableview.register(ACNLoginTableViewCell.self, forCellReuseIdentifier: "ACNLoginTableViewCell")
        tableview.delegate = self
        tableview.dataSource = self
        view.addSubview(tableview)
        
        login.backgroundColor = UIColor(red: 1/255.0, green: 2/255.0, blue: 141/255.0, alpha: 1)
        login.addTarget(self, action: #selector(bindBtnClick(_:)), for: .touchUpInside)
        if isLogin {
            login.setTitle("Login", for: .normal)
        } else {
            login.setTitle("Update", for: .normal)
        }
        
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 100))
        footView.addSubview(login)
        tableview.tableFooterView = footView
    }
    
    var dataArr: [ACNLoginModel] = []
    func initDataArr() {
        if isLogin {
            let model = ACNLoginModel()
            model.placeholder = "Input userID"
            model.title = "userID"
            dataArr.append(model)
        } else {
            
            if ACNUser.shared.userId == nil || ACNUser.shared.userId!.isEmpty {
                
                TWToast.showToast(text: "Login first in the update information")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            let arr = [["title": "userID", "placeholder": "Input userID"],
                       ["title": "nickname", "placeholder": "Input nickname"],
                       ["title": "avatarURL", "placeholder": "Input avatarURL"],
                       ["title": "phone number", "placeholder": "Input phone number"],
                       ["title": "email", "placeholder": "Input email"],
                       ["title": "sex", "placeholder": "0 is female, 1 is male"]]
            
            for model in arr {
                let m = ACNLoginModel()
                m.title = model["title"]
                m.placeholder = model["placeholder"]
                dataArr.append(m)
            }
            dataArr.first?.text = ACNUser.shared.userId
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableview.frame = CGRect(x: 0, y: 20, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 20)
        login.frame = CGRect(x: (view.bounds.size.width - 200) / 2.0, y: 50, width: 200, height: 44)
    }
    
    @objc private func bindBtnClick(_ sender: UIButton) {

        guard let userId = dataArr[0].text else {
            TWToast.showToast(text: "userID is not empty")
            return
        }

        if userId.isEmpty {
            TWToast.showToast(text: "userID is not empty")
            return
        }

        let user = ACNUserInfo(userId: userId)
        if isLogin {
            login(user: user)
        } else {
            user.avatarUrl = dataArr[2].text
            user.nickname = dataArr[1].text
            user.telephone = dataArr[3].text
            user.email = dataArr[4].text
            if dataArr[5].text == "0" {
                user.gender = "female"
            } else if dataArr[5].text == "1" {
                user.gender = "male"
            }
            updataUser(user: user)
        }
    }
    
    func login (user: ACNUserInfo) {
        ACNSDK.login(userInfo: user) { (success, error, _) -> Void in
            
            if success {
                
                TWToast.showToast(text: "Login success")
                ACNUser.shared.userId = user.userId
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            } else {
                print(String(describing: error?.errorDescription))
                TWToast.showToast(text: "Login faile\(String(describing: error?.errorDescription))")
            }
        }
    }

    func updataUser(user: ACNUserInfo) {
        
        ACNSDK.update(userInfo: user) { (success, error, _) -> Void in
            
            //返回的user 会增加ACN主链地址
            if success {
                TWToast.showToast(text: "Update success")
                self.dismiss(animated: true, completion: nil)
            } else {
                TWToast.showToast(text: "Update faile\(error?.errorDescription ?? "unknown")")
            }
        }
    }
    
}

extension ACNLoginViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACNLoginTableViewCell", for: indexPath) as! ACNLoginTableViewCell
        
        let model = dataArr[indexPath.row]
        cell.model = model
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
