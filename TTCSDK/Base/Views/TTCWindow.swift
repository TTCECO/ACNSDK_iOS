//
//  TTCWindow.swift
//  TTC_SDK
//
//  Created by Zhang Yufei on 2018/7/3  下午7:39.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit

class TTCWindow: UIWindow {

    static let shared = TTCWindow(frame: UIScreen.main.bounds)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.windowLevel = UIWindowLevelNormal + 100
        self.backgroundColor = UIColor.white

        let viewController = TTCViewController()
        viewController.view.backgroundColor = UIColor.white
        self.rootViewController = viewController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TTCWindow {

    override func makeKeyAndVisible() {
        super.makeKeyAndVisible()

        self.isHidden = false
    }

    func hiddenWindow() {
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        self.isHidden = true
    }
}
