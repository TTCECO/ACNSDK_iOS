//
//  ACNActionCell.swift
//  ACN_SDK_iOS_Demo
//
//  Created by Zhang Yufei on 2018/7/17  下午5:38.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import UIKit

class ACNActionCell: UICollectionViewCell {
    
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 1/255.0, green: 2/255.0, blue: 141/255.0, alpha: 1) //UIColor.cyan
        
        titleLabel.frame = self.bounds
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: String) {
        
        titleLabel.text = title
    }
}
