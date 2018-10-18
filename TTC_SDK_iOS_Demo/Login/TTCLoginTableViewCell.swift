//
//  TTCLoginTableViewCell.swift
//  TTC_SDK_iOS_Demo
//
//  Created by Zhang Yufei on 2018/7/20  下午3:32.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import UIKit

class TTCLoginTableViewCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        

        NotificationCenter.default.addObserver(self, selector: #selector(handleTextFieldTextDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    @objc private func handleTextFieldTextDidChange(notification: Notification) {
        
        guard let tf = notification.object as? UITextField else {
            return
        }
        
        if tf === textField {
            model?.text = textField.text
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    func setupSubviews() {
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        contentView.addSubview(textField)
    }
    
    var model: TTCLoginModel? {
        didSet {
            textField.placeholder = model?.placeholder
            textField.text = model?.text
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textField.frame = CGRect(x: 18, y: 3, width: self.bounds.size.width - 36, height: 44)
    }
}

extension TTCLoginTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        model?.text = textField.text
    }
}
