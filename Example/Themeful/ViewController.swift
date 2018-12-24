//
//  ViewController.swift
//  Themeful
//
//  Created by ws00801526 on 11/16/2018.
//  Copyright (c) 2018 ws00801526. All rights reserved.
//

import UIKit
import Themeful

class ViewController: UIViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    
    @IBOutlet weak var themeView: UIView!
    @IBOutlet weak var themeImageView: UIImageView!
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    
    fileprivate lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let _ = self.themeImageView.theme.setImage("main.imageView.image")
        let _ = self.navigationItem.theme.setTitle("main.title")
//        let _ = self.themeView.tf
//            .setBackgroundColor("main.view.backgroundColor")
//            .setAlpha("main.view.alpha")
//        let _ = self.themeSegmentedControl.tf
//            .setTintColor("main.segmented.tintColor")
////            .setHidden("main.segmented.hidden")
//            .setTitle("main.segmented.title1", forSegmentAt: 0)
//            .setTitle("main.segmented.title2", forSegmentAt: 1)
//            .setTitle("main.segmented.title3", forSegmentAt: 2)
////            .setEnabled("main.segmented.titleEnable2", forSegmentAt: 1)
//        // Do any additional setup after loading the view, typically from a nib.
//        let _ = self.themeLabel.tf
//            .setFont("main.label.font")
//            .setTextColor("main.label.color")
//            .setTextAlignment("main.label.align")
//
//        let _ = self.navigationController?.navigationBar.tf
//                .setTitleTextAttributes("main.nav.attributes")
//
//        let info = ThemeManager.shared.currentTheme?.info
//
//        let floatValue = (info?.value(forKeyPath: "main.view.alpha") as? Float)
//        let intValue = (info?.value(forKeyPath: "main.view.alpha") as? Int)
//        let doubleValue = (info?.value(forKeyPath: "main.view.alpha") as? Double)
//        let boolValue = (info?.value(forKeyPath: "main.view.alpha") as? Bool)
//        let floatValue2 = (info?.value(forKeyPath: "main.view.alpha") as? CGFloat)
//
//        let booValue2 = info?.value(forKeyPath: "main.segmented.titleEnable2") as? Int
//        print("get value from info \(floatValue) \(intValue) \(doubleValue) \(boolValue) \(booValue2) \(floatValue2)")
//
//        print("\(NSAttributedString.Key.font) \(NSAttributedString.Key.foregroundColor) \(NSAttributedString.Key.backgroundColor.rawValue)")
//
//        self.navigationItem.title = "测试数据"
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        ThemeManager.duration = 0
//        let themePath = ThemePath.mainBundle
//        if let name = ThemeManager.shared.currentTheme?.name, name == "Red.strings" {
//            let theme = Theme("Blue.strings", path: themePath)
//            let _ = ThemeManager.setTheme(theme: theme)
//        } else {
//            let theme = Theme("Red.strings", path: themePath)
//            let _ = ThemeManager.setTheme(theme: theme)
//        }
//    }
    
    @IBAction func handleThemeChanged(_ sender: UISwitch) {
//        ThemeManager.duration = (arc4random() % 2 == 0) ? 0.2 : 0.0
        
        print("session : \(session)")
        session.downloadTask(with: URL(string: "https://www.baidu.com")!).resume()
        session.invalidateAndCancel()
        print("session after: \(session)")
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        print("session after init: \(session)")

        let themePath = ThemePath.mainBundle
        let theme = sender.isOn ? Theme("Valentine.strings", path: themePath) : Theme("Chinese.strings", path: themePath)
        let _ = ThemeManager.setTheme(theme: theme)
        
//        themeLabel.text = theme.name
    }
}

extension ViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
}
