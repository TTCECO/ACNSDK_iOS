//
//  AppDelegate.swift
//  ACN_SDK_iOS_Demo
//
//  Created by Zhang Yufei on 2018/7/2  下午4:07.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit
import ACNSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
//        ACNRegister.sdk(isEnabled: false)
        ACNSDK.log(isEnabled: true)
        
        let TTC_APPID = "tataufo"
        let TTC_SECRET_KEY = "9d1990b8fc9cf1328d88af73b8f89e4d"
        ACNSDK.register(appId: TTC_APPID, secretKey: TTC_SECRET_KEY, environment: .develop) { (result, error) in
            if result {
                print("register success")
            } else {
                print("register faile\(String(describing: error?.errorDescription))")
            }
        }
        
//        ACNSDK.register(appId: "SDKTest", secretKey: "9d1990b8fc9cf1328d88af73b8f89e4d", environment: .develop) { (result, error) in
//            if result {
//                print("register success")
//            } else {
//                print("register faile\(String(describing: error?.errorDescription))")
//            }
//        }

        let vc = ViewController()
        window!.rootViewController = vc
        window!.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let result = ACNSDK.handleApplication(openURL: url)
        return result
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let result = ACNSDK.handleApplication(openURL: url)
        return result
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let result = ACNSDK.handleApplication(openURL: url)
        return result
    }
}
