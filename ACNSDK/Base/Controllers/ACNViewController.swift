//
//  ACNViewController.swift
//  ACN_SDK
//  
//  Created by Zhang Yufei on 2018/7/4  下午1:00.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit

class ACNViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if !ACNWindow.shared.isKeyWindow {
            ACNWindow.shared.makeKeyAndVisible()
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            completion?()

            if ACNWindow.shared.rootViewController?.presentedViewController == nil {
                ACNWindow.shared.hiddenWindow()
            }
        }
    }

}
