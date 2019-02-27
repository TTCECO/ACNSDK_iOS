//
//  AppDelegate.swift
//  TTC_SDK_iOS_Demo
//
//  Created by Zhang Yufei on 2018/7/2  下午4:07.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit
import TTCSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
//        TTCRegister.sdk(isEnabled: false)
        TTCSDK.log(isEnabled: true)
        
        TTCSDK.register(appId: "SDKTest", secretKey: "9d1990b8fc9cf1328d88af73b8f89e4d", environment: 1) { (result, error) in
            if result {
                print("register success")
            } else {
                print("register faile\(String(describing: error?.errorDescription))")
            }
        }

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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let result = TTCSDK.handleApplication(openURL: url)
        return result
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let result = TTCSDK.handleApplication(openURL: url)
        return result
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let result = TTCSDK.handleApplication(openURL: url)
        return result
    }
}
