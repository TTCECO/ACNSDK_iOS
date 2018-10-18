//
//  TTCUploadViewController.swift
//  TTC_SDK_iOS_Demo
//  
//  Created by Zhang Yufei on 2018/7/20  下午5:34.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import UIKit
import TTCSDK

class TTCUploadViewController: UIViewController {

    let closeBtn = UIButton(frame: CGRect(x: 9, y: 20, width: 44, height: 44))
    let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let textView = UITextView(frame: CGRect(x: 0, y: 44, width: 375, height: 400))
    let upload = UIButton(frame: CGRect(x: 0, y: 50, width: 200, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupSubviews()
    }
    
    func setupSubviews() {
        
        view.addSubview(closeBtn)
        closeBtn.setTitleColor(UIColor.black, for: .normal)
        closeBtn.setTitle("╳", for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClick(_:)), for: .touchUpInside)
        
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "actionType:101-post 102-like 103-comment 104-share 105-video play 106-file upload 107-report 108-advertisement"
        textField.keyboardType = .phonePad
        view.addSubview(textField)
        
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let extra = "{\"actionType\":\"101\",\"userID\":\"\(TTCUser.shared.userId!)\",\"content\":\"Send a post\",\"timestamp\":\"\(timestamp)\"}"
        
        textView.text = extra
        textView.backgroundColor = UIColor.lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(textView)
        
        upload.backgroundColor = UIColor(red: 1/255.0, green: 2/255.0, blue: 141/255.0, alpha: 1)
        upload.addTarget(self, action: #selector(bindBtnClick(_:)), for: .touchUpInside)
        upload.setTitle("Upload", for: .normal)
        view.addSubview(upload)
    }
    
    @objc private func bindBtnClick(_ sender: UIButton) {
        
        guard let extra = textView.text else { return TWToast.showToast(text: "extra is empty") }
        
        guard let action = textField.text, let acType = Int32(action) else { return TWToast.showToast(text: "acType is error") }
        
        TTCUploadAction.uploadAction(actionType: acType, extra: extra) { [weak self] (success, error) in
            guard let strongSelf = self else {
                return
            }
            
            if success {
                TWToast.showToast(text: "Upload success")
                let actionType = arc4random_uniform(9) + 101
                strongSelf.textField.text = String(actionType)
                let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
                let extra = "{\"actionType\":\"\(actionType)\",\"userID\":\"\(TTCUser.shared.userId!)\",\"content\":\"this is a action\",\"timestamp\":\"\(timestamp)\"}"
                
                strongSelf.textView.text = extra
            } else {
                TWToast.showToast(text: "Upload faile:\(String(describing: error?.errorDescription))")
            }
        }
    }
    
    @objc private func closeBtnClick(_ sender: UIButton) {
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let width = view.bounds.size.width
        
        textField.frame = CGRect(x: 18, y: 64, width: width - 36, height: 44)
        textView.frame = CGRect(x: 18, y: textField.frame.maxY + 20, width: width - 36, height: 200)
        upload.frame = CGRect(x: 18, y: textView.frame.maxY + 20, width: width - 36, height: 44)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
