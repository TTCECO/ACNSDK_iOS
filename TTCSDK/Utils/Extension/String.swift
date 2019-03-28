//
//  String.swift
//  TTC_SDK
//
//  Created by zhangliang on 2018/7/4.
//  Copyright © 2018 tataufo. All rights reserved.
//

import Foundation
import AdSupport

extension String {
    var drop0x: String {
        
        if self.count > 2 && self.hasPrefix("0x") {
            return String(self.dropFirst(2))
        }
        return self
    }

    var add0x: String {
        return "0x" + self
    }
    
    var isHex: Bool {
        
        if self.hasPrefix("t") {
            return true
        } else if self.hasPrefix("0x") {
            return true
        }
        
        return false
    }
    
    var withOutHex: String {
        
        if isHex {
            return String(self.dropFirst(2))
        }
        
        return self
    }
    
    var to0x: String {
        
        return "0x" + self.withOutHex
    }
}

extension String {
    func addUser() -> String {
        
        guard let userid = TTCManager.shared.userInfo?.userId else {
            return "\(self)_NoUser"
        }
        
        return "\(self)_user_\(userid)"
    }
}


extension String {

    /// 计算文本宽度
    func textWidth(font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight)

        #if swift(>=4.0)
        let dict = [NSAttributedStringKey.font: font]
        #else
        let dict = [NSFontAttributeName: font]
        #endif
        let options: NSStringDrawingOptions = [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading]
        let stringSize = self.boundingRect(with: size, options: options, attributes: dict, context: nil).size
        return CGFloat(ceilf(Float(stringSize.width)))
    }
    
    /// 根据最大宽度计算文本实际高度
    func textHeight(font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        #if swift(>=4.0)
        let dict = [NSAttributedStringKey.font: font]
        #else
        let dict = [NSFontAttributeName: font]
        #endif
        let options: NSStringDrawingOptions = [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading]
        let stringSize = self.boundingRect(with: size, options: options, attributes: dict, context: nil).size
        return CGFloat(ceilf(Float(stringSize.height)))
    }
    
    static func getUUID() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}
