//
//  TTCAppIcon.swift
//  TTC_SDK
// 
//  Created by Zhang Yufei on 2018/7/12  下午2:39.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import UIKit

class TTCAppIcon: UIView {
    
    let appIcon: UIImageView = UIImageView()
    let titleLabel: UILabel = UILabel()

    init() {
        super.init(frame: CGRect(origin: CGPoint(x: 80, y: 144), size: CGSize(width: 120, height: 93)))
        appIcon.frame = CGRect(x: 30, y: 5, width: 60, height: 60)
        appIcon.backgroundColor = UIColor.lightGray
        appIcon.layer.cornerRadius = 10
        appIcon.layer.masksToBounds = true
        self.addSubview(appIcon)

        let layerFrame = CGRect(x: appIcon.frame.origin.x - 1, y: appIcon.frame.origin.y - 1, width: appIcon.frame.size.width + 2, height: appIcon.frame.size.height + 2)
        let shadowPath = UIBezierPath(roundedRect: layerFrame, cornerRadius: 4.5)
        let layer = CALayer()
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.insertSublayer(layer, at: 0)
        
        titleLabel.frame = CGRect(x: 0, y: 77, width: frame.size.width, height: 16)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor(red: 43/255.0, green: 46/255.0, blue: 61/255.0, alpha: 1)
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAppiconAndTitle(icon: UIImage?, title: String?) {
        
        appIcon.image = icon
        titleLabel.text = title
    }
    
}
