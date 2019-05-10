//
//  ACNNavigationController.swift
//  ACN_SDK
//  
//  Created by Zhang Yufei on 2018/7/3  下午7:59.
//  Copyright © 2018年 tataufo. All rights reserved.
//

import UIKit

class ACNNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

    }

}

extension ACNNavigationController {

//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
//    }
//    
//    override func popViewController(animated: Bool) -> UIViewController? {
//        let viewController = super.popViewController(animated: animated)
//        
//        if self.viewControllers.first == viewController {
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
//        }
//        
//        return viewController
//    }
//    
//    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
//        
//        let viewControllers = super.popToRootViewController(animated: animated)
//        UIApplication.shared.windows.first?.makeKeyAndVisible()
//        
//        return viewControllers
//    }
//    
//    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
//        let viewControllers = super.popToRootViewController(animated: animated)
//        UIApplication.shared.windows.first?.makeKeyAndVisible()
//        
//        return viewControllers
//    }

}
