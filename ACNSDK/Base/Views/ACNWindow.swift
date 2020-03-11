//
//  ACNWindow.swift
//  ACN_SDK
//
//  Created by Zhang Yufei on 2018/7/3  下午7:39.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit

class ACNWindow: UIWindow {

    static let shared = ACNWindow(frame: UIScreen.main.bounds)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.windowLevel = UIWindow.Level.normal + 100
        self.backgroundColor = UIColor.white

        let viewController = ACNViewController()
        viewController.view.backgroundColor = UIColor.white
        self.rootViewController = viewController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ACNWindow {

    override func makeKeyAndVisible() {
        super.makeKeyAndVisible()

        self.isHidden = false
    }

    func hiddenWindow() {
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        self.isHidden = true
    }
}
