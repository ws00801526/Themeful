//  ThemeManager.swift
//  Pods
//
//  Created by  XMFraker on 2018/11/16
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      ThemeManager
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

public let ThemeDidUpdateNotification: Notification.Name = Notification.Name(rawValue: "ThemeDidUpdateNotification")
private let TMThemeInfoKey = "ThemeInfosKey"
private let TMCurrentThemeKey = "CurrentThemeKey"

public enum ThemePath {
    case mainBundle
    case sandbox(Foundation.URL)
    
    public var URL:Foundation.URL? {
        switch self {
        case .sandbox(let path)  : return path
        case .mainBundle         : return nil
        }
    }
}

public class Theme : NSObject {
    
    public var name: String = ""
    public var path: ThemePath = .mainBundle
    public lazy var info: NSDictionary? = {
        switch self.path {
        case .mainBundle:
            if let URL = Bundle.main.url(forResource: self.name, withExtension: nil) {
                return URL.JSON()
            }
            return nil
        case .sandbox(let URL): return URL.JSON()
        }
    }()
    
    required public init(_ name: String, path: ThemePath) {
        super.init()
        self.name = name
        self.path = path
    }
    
    public static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.name == rhs.name && lhs.info == rhs.info
    }
}

fileprivate extension URL {
    func JSON() -> NSDictionary? {
        
        if self.pathExtension == "plist", let info = NSDictionary(contentsOf: self) {
            return info
        }
        
        if let data = NSData(contentsOf: self) {
            let json = try? JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? NSDictionary
            return json ?? nil
        }
        
        return nil
    }
}

public class ThemeManager {
    
    // animation duration changing theme
    public static var duration = 0.3
    public var themes: [Theme] = [Theme]()
    public var currentTheme: Theme? {
        didSet {
            
            let infos = themes.map { (theme) -> [String : String] in
                if let URL = theme.path.URL { return ["name" : theme.name, "path" : URL.absoluteString ] }
                return ["name" : theme.name]
            }
            if !infos.isEmpty { UserDefaults.standard.set(infos, forKey: TMThemeInfoKey) }
            
            if let theme = currentTheme { UserDefaults.standard.setValue(theme.name, forKeyPath: TMCurrentThemeKey) }
            UserDefaults.standard.synchronize()
        }
    }
    
    public static let shared = ThemeManager()
    
    convenience init(_ theme: Theme?) {
        self.init()
        
        if let infos = UserDefaults.standard.array(forKey: TMThemeInfoKey) as? [[String : String]] {
            
            let themes = infos.compactMap { (info) -> Theme? in
                guard let path = info["path"] else { return Theme(info["name"] ?? "", path: ThemePath.mainBundle) }
                return Theme(info["name"] ?? "", path: ThemePath.sandbox(URL(fileURLWithPath: path)))
            }
            self.themes.append(contentsOf: themes)
        }
        
        if let t = theme {
            _ = ThemeManager.setTheme(theme: t);
        } else if let name = UserDefaults.standard.string(forKey: TMCurrentThemeKey) {
            _ = ThemeManager.setTheme(name: name)
        } else if let t = themes.first {
            _ = ThemeManager.setTheme(theme: t)
        }
    }
    
    public class func setTheme(name: String) -> Bool {
        
        guard let theme = ThemeManager.shared.themes.first(where: { $0.name == name }) else {
            debugPrint("cannot find theme with name :[\(name)]")
            return false
        }
        return setTheme(theme: theme)
    }
    
    public class func setTheme(theme: Theme) -> Bool {
        
        guard let _ = theme.info else {
            debugPrint("cannot load info of theme :[\(theme.name)]")
            return false
        }
        
        if ThemeManager.shared.themes.contains(theme) == false { ThemeManager.shared.themes.append(theme) }
        ThemeManager.shared.currentTheme = theme
        NotificationCenter.default.post(name: ThemeDidUpdateNotification, object: nil)
        return true
    }
}
