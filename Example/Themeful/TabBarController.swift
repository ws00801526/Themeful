//  TabBarController.swift
//  Themeful
//
//  Created by  XMFraker on 2018/12/10
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      TabBarController
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit
import Themeful

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.tabBarItem.tf
        //        print("this is tf \(self.tabBarItem.tf)")
        
        self.tabBar.isTranslucent = false
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()

        let _ = self.tabBar.theme.setBackgroundImage("Global.tab.backgroundImage").setShadowImage("Global.tab.shadowImage")
//        let _ = self.tabBar.theme.setBackgroundColorImage("Global.tab.backgroundColor")

        guard let items = self.tabBar.items else { return }
        for (index, item) in items.enumerated() {
            
            let _ = item.theme
                .setTitle("Global.tab_\(index).title")
                .setImage("Global.tab_\(index).image")
                .setSelectedImage("Global.tab_\(index).selectedImage")
                .setTitleTextAttributes("Global.tab_attributes", for: .normal)
                .setTitleTextAttributes("Global.tab_attributes_selected", for: .selected)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let controller = self.selectedViewController {
            return controller.preferredStatusBarStyle
        }
        return .default
    }
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let controller = self.topViewController {
            return controller.preferredStatusBarStyle
        }
        return .default
    }
}

extension UIImage {
    
    class func image(with color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage? {
        
        guard size.width > 0, size.height > 0 else { return nil }
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
