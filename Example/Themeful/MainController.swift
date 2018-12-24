//  MainController.swift
//  Themeful
//
//  Created by  XMFraker on 2018/12/11
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      MainController
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit
import Themeful
import CoreLocation
class MainController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        
        if let URL = Bundle.main.url(forResource: "Valentine", withExtension: "strings") {
            print("URL \(URL)")
            print("URL after delete last component \(URL.deletingLastPathComponent())")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {

        return ThemeStatusBarStylePicker.init("Global.status").style
    }
    
    fileprivate func setupTheme() {
        
        let _ = self.nameLabel.theme.setText("main.name")
        let _ = self.imageView.theme.setImage("main.image")
        let _ = self.navigationItem.theme.setTitle("main.title")
        
        let _ = self.navigationController?.navigationBar.theme
            .setBackgroundColorImage("Global.nav.backgroundColor")
            .setTitleTextAttributes("Global.nav.textAttributes")
    }
    
    @IBAction func handleThemeChanged(_ sender: UISwitch) {
//        ThemeManager.duration = (arc4random() % 2 == 0) ? 0.2 : 0.0
        ThemeManager.duration = 0
        let themePath = ThemePath.mainBundle
        let theme = sender.isOn ? Theme("Valentine.strings", path: themePath) : Theme("Chinese.strings", path: themePath)
        let _ = ThemeManager.setTheme(theme: theme)
        setNeedsStatusBarAppearanceUpdate()
//        if let image = ThemeManager.colorImage("Global.nav.backgroundColor") {
//            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
//        }
    }
}
