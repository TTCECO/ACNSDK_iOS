//
//  TTCImage.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/4  下午6:28.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation

let SDLBundle = Bundle(url: Bundle.main.url(forResource: "TTCSDKBundle", withExtension: "bundle")!)!

extension UIImage {

    static func TTCImg(name: String) -> UIImage? {
        return UIImage(named: name, in: SDLBundle, compatibleWith: nil)
    }
}
