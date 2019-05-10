//
//  ACNUploadAction.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/3  上午10:16.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import Foundation

public class ACNUploadAction: NSObject {

    /// Behavior upload
    ///
    /// - Parameters:
    /// - actionType: Behavior Type Must Be Greater Than 100
    /// - extra: Behavior information, must be spliced into json strings
    /// - result:
    @objc public static func uploadAction(actionType: Int32, extra: String, result: ((Bool, ACNSDKError?) -> Void)? ) {
        
        if actionType <= 100 {
            result?(false, ACNSDKError(type: .ActionType100))
            return
        }
        
        if !ACNManager.shared.SDKEnabled {
            result?(false, ACNSDKError(type: .SDKDisable))
            return
        }

        if extra.isEmpty {
            ACNManager.shared.handleUserActionInfo(actionType: actionType, extra: extra)
            result?(true, nil)
            return
        }
        
        do {
    
            // Json format
            _ = try JSONSerialization.jsonObject(with: extra.data(using: .utf8) ?? Data(), options: .mutableContainers)
            
            if ACNManager.shared.isLogin {
                ACNManager.shared.handleUserActionInfo(actionType: actionType, extra: extra)
                result?(true, nil)
            } else {
                result?(false, ACNSDKError(type: .LoginNo))
            }
            
        } catch {
            result?(false, ACNSDKError(type: .ExtraNotJson))
        }
    }
}
