//
//  ACNImage.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/4  下午6:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation

extension UIImage {

    static func ACNImg(name: String) -> UIImage? {
        if let bundle = UIImage.getBundle(),
            let img = UIImage(named: name, in: bundle, compatibleWith: nil) {
            return img
        }
        return UIImage()
    }
    
    static func getBundle() -> Bundle? {
        if let path = Bundle(for: ACNSDK.self).path(forResource: "TTCSDKBundle", ofType: "bundle") {
            return Bundle(path: path)
        }
        
        return nil
    }
}
