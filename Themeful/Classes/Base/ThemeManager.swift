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
        case .sandbox(let URL)  : return URL
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
            if let URL = Bundle.main.url(forResource: self.name, withExtension: nil) { return URL.JSON() }
            return nil
        case .sandbox(let URL):
            if URL.isJSONFile { return URL.JSON() }
            var isDirValue: ObjCBool = ObjCBool(false)
            let isExists = FileManager.default.fileExists(at: URL, isDirectory: &isDirValue)
            guard isExists, isDirValue.boolValue else { return nil }
            if let value = URL.appendingPathComponent(name).appendingPathExtension(JSONFileExtension).JSON() { return value }
            if let value = URL.appendingPathComponent(name).appendingPathExtension(PlistFileExtension).JSON() { return value }
            return nil
        }
    }()
    
    required public init(_ name: String, path: ThemePath = .mainBundle, info: NSDictionary? = nil) {
        super.init()
        self.name = name
        self.path = path
        if let _ = info { self.info = info }
    }
    
    public static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.name == rhs.name && lhs.info == rhs.info
    }
    
    public override var hash: Int {
        if case let .sandbox(URL) = self.path { return self.name.hashValue ^ URL.hashValue }
        return self.name.hashValue
    }
}

fileprivate extension URL {
    
    fileprivate var isJSONFile: Bool {
        return self.pathExtension == PlistFileExtension || self.pathExtension == JSONFileExtension
    }
    
    func JSON() -> NSDictionary? {
        
        if self.pathExtension == PlistFileExtension, let info = NSDictionary(contentsOf: self) {
            return info
        }
        
        if let data = NSData(contentsOf: self) {
            let json = try? JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as? NSDictionary
            return json ?? nil
        }
        
        return nil
    }
}

fileprivate extension Array where Element: Hashable {
    
    func filterDuplicate() -> [Element] {
        if self.isEmpty { return [] }
        return Array(Set(self))
    }
}

public class ThemeManager {
    
    // animation duration changing theme
    public static var duration = 0.0
    public var themes: [Theme] = [Theme]()
    public var currentTheme: Theme? {
        didSet {
            
            guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
            let infos = themes.map { (theme) -> [String : String] in
                // should not using path.URL directly as saving key, it will changing after update or installed
                if let URL = theme.path.URL { return ["name" : theme.name, "path" : URL.path.replacingOccurrences(of: dir, with: "") ] }
                return ["name" : theme.name]
            }.filterDuplicate()
            if infos.isEmpty == false { UserDefaults.standard.set(infos, forKey: TMThemeInfoKey) }
            
            if let theme = currentTheme { UserDefaults.standard.setValue(theme.hash, forKeyPath: TMCurrentThemeKey) }
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: ThemeDidUpdateNotification, object: nil)
        }
    }
    
    public static let shared = ThemeManager()
    
    required init(_ theme: Theme? = nil) {
        
        if let infos = UserDefaults.standard.array(forKey: TMThemeInfoKey) as? [[String : String]] {
            
            guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }

            let themes = infos.compactMap { (info) -> Theme? in
                
                guard let name = info["name"] else { return nil }
                var theme: Theme? = nil
                
                if let path = info["path"] {
                    theme = Theme(name, path: .sandbox(URL(fileURLWithPath: "\(dir)\(path)")))
                } else {
                    theme = Theme(name)
                }
                return (theme?.isExists ?? false) ? theme : nil
            }
            self.themes.append(contentsOf: themes)
        }
        
        if let t = theme {
            self.currentTheme = t
//            _ = ThemeManager.setTheme(theme: t);
        } else if let t = themes.first(where: { $0.hash == UserDefaults.standard.integer(forKey: TMCurrentThemeKey) }) {
            self.currentTheme = t
//            _ = ThemeManager.setTheme(name: name)
        } else if let t = themes.last {
            self.currentTheme = t
//          _ = ThemeManager.setTheme(theme: t)
        }
    }
    
    public class func setTheme(name: String) -> Bool {
        
        guard let theme = shared.themes.first(where: { $0.name == name }) else {
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
        
        if shared.themes.contains(theme) == false { shared.themes.append(theme) }
        shared.currentTheme = theme
        return true
    }
}
