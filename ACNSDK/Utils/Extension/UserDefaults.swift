//
//  ACNUserDefaults.swift
//  ACNSDK
//
//  Created by chenchao on 2018/10/16.
//  Copyright © 2018 tataufo. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    struct Key {
        static let lastDayNumber: String = "lastDayNumber"
    }
}

extension UserDefaults {

    // MARK: -- last day
    static var lastDayNumber: Int {
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.lastDayNumber.addUser())
            UserDefaults.standard.synchronize()
        }
        
        get {
            let time = UserDefaults.standard.integer(forKey: UserDefaults.Key.lastDayNumber.addUser())
            guard time > 0 else { return 0 }
            return time
        }
    }
}
