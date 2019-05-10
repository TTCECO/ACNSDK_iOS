//
//  ACNLog.swift
//  ACNSDK
//
//  Created by Zhang Yufei on 2018/7/23  下午6:04.
//  Copyright © 2018年 tataufo. All rights reserved.
//


import Foundation

func ACNPrint(_ item: String) {
    
    if !ACNManager.shared.logEnable {
        return
    }
    
    print("ACN LOG : " + item)
}

//func ACNPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//    jointString(items, separator: separator, terminator: terminator)
//}
//
//func jointString(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//
//    if !ACNManager.shared.logEnable {
//        return
//    }
//
//    print(items)
//
////    var log: String = ""
////    print(items, separator: separator, terminator: terminator, to: &log)
//
////    ACNLog.manager.writeToFile(content: log)
//}

class ACNLog {
    
    static let manager = ACNLog()
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/acnlog.txt"
    let dateformatter = DateFormatter()
    
    init() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path, contents: nil)
        }
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    }
    
    func writeToFile(content: String) {
        
        let log = dateformatter.string(from: Date()) + " " + content
        guard let data = log.data(using: String.Encoding.utf8), let writeHandler = try? FileHandle(forWritingTo:URL(string: path)!)  else { return }
        
        writeHandler.seekToEndOfFile()
        writeHandler.write(data)
    }
}
