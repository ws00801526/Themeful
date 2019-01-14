//  ThemePicker.swift
//  Pods
//
//  Created by  XMFraker on 2018/11/16
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      ThemePicker
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

public let ResourcesPathComponent = "resources"
internal let ZIPFileExtension = "zip"
internal let JSONFileExtension = "json"
internal let PlistFileExtension = "plist"

public extension ThemeManager {
    public class func getValue<ValueType>(for keyPath: String) -> ValueType? {
        guard let info = shared.currentTheme?.info else { return nil }
        guard let value = info.value(forKeyPath: keyPath) as? ValueType else { return nil }
        return value
    }
}

public extension ThemeManager {
    
    public class func string(_ keyPath: String) -> String? {
        
        guard let info = shared.currentTheme?.info else { return nil }
        guard let value = info.value(forKeyPath: keyPath) as? String else { return nil }
        return value
    }
    
    public class func number(_ keyPath: String) -> NSNumber? {
        
        guard let info = shared.currentTheme?.info else { return nil }
        guard let value = info.value(forKeyPath: keyPath) as? NSNumber else { return nil }
        return value
    }
    
    public class func textAttributes(_ keyPath: String) -> [NSAttributedString.Key : Any]? {
        guard let info = dictionary(keyPath) else { return nil }
        var attributed: [NSAttributedString.Key : Any] = [:]
        
        for item in info {
            
            guard let ikey = item.key as? String else { continue }
            let rkey: NSAttributedString.Key = NSAttributedString.Key.init(ikey)
            switch rkey {
                
            case .ligature where item.value is NSNumber: fallthrough
            case .kern where item.value is NSNumber: fallthrough
            case .strikethroughStyle where item.value is NSNumber: fallthrough
            case .underlineStyle where item.value is NSNumber: fallthrough
            case .strokeWidth where item.value is NSNumber: fallthrough
            case .obliqueness where item.value is NSNumber: fallthrough
            case .expansion where item.value is NSNumber: attributed[rkey] = item.value
                
            case .strokeColor where item.value is String: fallthrough
            case .underlineColor where item.value is String: fallthrough
            case .strikethroughColor where item.value is String: fallthrough
            case .backgroundColor where item.value is String: fallthrough
            case .foregroundColor where item.value is String: attributed[rkey] = UIColor(item.value as! String)
            case .font where item.value is String: attributed[rkey] = UIFont.font(with: item.value as! String)
            default: break
            }
        }
        return attributed
    }
    
    //    public class func value(_ keyPath: String) -> NSValue? {
    //
    //        guard let string = string(keyPath) else { return nil }
    //        guard let value = NSValue(string)  else { return nil }
    ////        guard let info = shared.currentTheme?.info else { return nil }
    ////        guard let string = info.value(forKeyPath: keyPath) as? NSValue else { return nil }
    ////        guard let value = info.value(forKeyPath: keyPath) as? NSValue else { return nil }
    //        return value
    //    }
    
    public class func dictionary(_ keyPath: String) -> NSDictionary? {
        
        guard let info = shared.currentTheme?.info else { return nil }
        guard let dict = info.value(forKeyPath: keyPath) as? NSDictionary  else { return nil }
        return dict
    }
    
    public class func color(_ keyPath: String) -> UIColor? {
        
        guard let hex = string(keyPath) else { return nil }
        guard let color = UIColor(hex) else { return nil }
        return color
    }
    
    public class func colorImage(_ keyPath: String) -> UIImage? {

        guard let color = color(keyPath) else { return nil }
        return UIImage.image(with: color)
    }
    
    public class func image(_ keyPath: String) -> UIImage? {
        
        guard let imageName = string(keyPath) else { return nil }
        if let dir = shared.currentTheme?.path.URL {
            if let image = UIImage(contentsOfFile: dir.appendingPathComponent(imageName).path) {
                return image
            } else if let image = UIImage(contentsOfFile: dir.appendingPathComponent(ResourcesPathComponent).appendingPathComponent(imageName).path) {
                return image
            } else {
                print("Themeful WARNING: Not found image name [\(imageName)] at path [\(dir.path)]");
                return nil
            }
        } else {
            guard let image = UIImage(named: imageName) else { print("Themeful WARNING: Not found image name at main bundle: \(imageName)"); return nil }
            return image
        }
    }
    
    /// get UIFont from a style
    /// support style of (font.name,font.size,font.weight)
    /// - Parameter keyPath: the key path of style
    /// - Returns: Optional(UIFont)
    public class func font(_ keyPath: String) -> UIFont? {
        guard let string = string(keyPath) else { return nil }
        return UIFont.font(with: string)
    }
}

open class ThemePicker {
    
    public typealias ValuePicker = () -> Any?
    public var valuePicker: ValuePicker
    required public init(v: @escaping ValuePicker) {
        self.valuePicker = v
    }
}

open class ThemeMultiPicker<KeyType>: ThemePicker where KeyType : Hashable {
    
    public typealias ValuePicker = () -> Any?
    public var valuePickers: [KeyType : ValuePicker] = [:]
    
    required public init(v: @escaping ValuePicker, for key: KeyType) {
        super.init { return nil }
        self.valuePickers[key] = v
    }
    
    required public init(v: @escaping ValuePicker) {
        fatalError("init(v:) has not been implemented, using init(v:forKey:) insteaded")
    }
    
    public func setPicker(v: @escaping ValuePicker, for key: KeyType) {
        self.valuePickers[key] = v
    }
}

public class ThemeImagePicker: ThemePicker {
    
    public var rawValue: UIImage? { return valuePicker() as? UIImage }
    public convenience init(_ keyPath: String, rendering mode: UIImage.RenderingMode = .automatic) {
        self.init {
            if let image = ThemeManager.image(keyPath) {
                if mode == .automatic { return image}
                else { return image.withRenderingMode(mode) }
            }
            return ThemeManager.image(keyPath)
        }
    }
}

public class ThemeColorPicker: ThemePicker {
    
    public var rawValue: UIColor? { return valuePicker() as? UIColor }
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.color(keyPath) }
    }
}

public class ThemeNumberPicker: ThemePicker {
    public var rawValue: NSNumber? { return valuePicker() as? NSNumber }
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.number(keyPath) }
    }
}

public class ThemeValuePicker: ThemePicker {
    public var rawValue: NSValue? { return valuePicker() as? NSValue }
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.number(keyPath) }
    }
}

public class ThemeStringPicker: ThemePicker {
    public var rawValue: String? { return valuePicker() as? String }
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.string(keyPath) }
    }
}

public class ThemeFontPicker: ThemePicker {
    public var rawValue: UIFont? { return valuePicker() as? UIFont }
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.font(keyPath) }
    }
}

public class ThemeAttirbutesPicker: ThemePicker {
    public var rawValue: [NSAttributedString.Key : Any]? { return valuePicker() as? [NSAttributedString.Key : Any] }
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.textAttributes(keyPath) }
    }
}

public class ThemeBackgroundImagePicker: ThemePicker {
    
    public var rawValue: UIImage? { return valuePicker() as? UIImage }
    public var barMetrics: UIBarMetrics = .defaultPrompt
    public var barPosition: UIBarPosition = .any
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.image(keyPath) }
    }
    
    public convenience init(colorKeyPath keyPath: String) {
        self.init { ThemeManager.colorImage(keyPath) }
    }
}

public class ThemeStatusBarStylePicker: ThemePicker {
    
    public var animated: Bool = true
    public var style: UIStatusBarStyle {
        guard let value = valuePicker() as? String else { return .default }
        switch value {
        case "UIStatusBarStyleLightContent": return .lightContent
        case "UIStatusBarStyleDefault": fallthrough
        default: return .default
        }
    }
    
    public convenience init(_ keyPath: String, animated: Bool = true) {
        self.init { return ThemeManager.string(keyPath) }
        self.animated = animated
    }
}

// MARK: SubClass Of ValuePicker

// MARK: SubClass Of NumberPicker

public final class ThemeBoolPicker: ThemeNumberPicker {
    public func boolValue(_ defaultValue: Bool = false) -> Bool { return self.rawValue?.boolValue ?? defaultValue }
}

public final class ThemeIntPicker: ThemeNumberPicker {
    public func intValue(_ defaultValue: Int = 0) -> Int { return self.rawValue?.intValue ?? defaultValue }
}

public final class ThemeFloatPicker: ThemeNumberPicker {
    public func floatValue(_ defaultValue: Float = 0.0) -> Float { return self.rawValue?.floatValue ?? defaultValue }
}

public final class ThemeDoublePicker: ThemeNumberPicker {
    public func doubleValue(_ defaultValue: Double = 0.0) -> Double { return self.rawValue?.doubleValue ?? defaultValue }
}
