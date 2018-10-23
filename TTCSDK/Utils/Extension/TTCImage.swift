//
//  TTCImage.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/4  下午6:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation

let SDKBundle = Bundle(path: "\(Bundle.main.resourcePath?.description ?? "")/TTCSDKBundle.bundle")

extension UIImage {

    static func TTCImg(name: String) -> UIImage? {
        
        guard let bundle = SDKBundle else { return UIImage() }
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
