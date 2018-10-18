//
//  TTCUploadAction.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/3  上午10:16.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation

public class TTCUploadAction: NSObject {

    /// Behavior upload
    ///
    /// - Parameters:
    /// - actionType: Behavior Type Must Be Greater Than 100
    /// - extra: Behavior information, must be spliced into json strings
    /// - result:
    @objc public static func uploadAction(actionType: Int32, extra: String, result: ((Bool, TTCSDKError?) -> Void)? ) {
        
        if actionType <= 100 {
            result?(false, TTCSDKError(type: .ActionType100))
            return
        }
        
        if !TTCManager.shared.SDKEnabled {
            result?(false, TTCSDKError(type: .SDKDisable))
            return
        }

        if extra.isEmpty {
            TTCManager.shared.handleUserActionInfo(actionType: actionType, extra: extra)
            result?(true, nil)
            return
        }
        
        do {
    
            // Json format
            _ = try JSONSerialization.jsonObject(with: extra.data(using: .utf8) ?? Data(), options: .mutableContainers)
            
            if TTCManager.shared.isLogin {
                TTCManager.shared.handleUserActionInfo(actionType: actionType, extra: extra)
                result?(true, nil)
            } else {
                result?(false, TTCSDKError(type: .LoginNo))
            }
            
        } catch {
            result?(false, TTCSDKError(type: .ExtraNotJson))
        }
    }
}
