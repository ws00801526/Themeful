//  ThemePicker.swift
//  Pods
//
//  Created by  XMFraker on 2018/11/16
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      ThemePicker
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

fileprivate extension UIColor {
    
    convenience init(_ hex3: UInt16, alpha: CGFloat = 1, displayP3: Bool = false) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex3 & 0xF00) >> 8) / divisor
        let green   = CGFloat((hex3 & 0x0F0) >> 4) / divisor
        let blue    = CGFloat( hex3 & 0x00F      ) / divisor
        if displayP3, #available(iOS 10, *) {
            self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    convenience init(_ hex4: UInt16, displayP3: Bool = false) {
        let divisor = CGFloat(15)
        let red     = CGFloat((hex4 & 0xF000) >> 12) / divisor
        let green   = CGFloat((hex4 & 0x0F00) >>  8) / divisor
        let blue    = CGFloat((hex4 & 0x00F0) >>  4) / divisor
        let alpha   = CGFloat( hex4 & 0x000F       ) / divisor
        if displayP3, #available(iOS 10, *) {
            self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    convenience init(_ hex6: UInt32, alpha: CGFloat = 1, displayP3: Bool = false) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        if displayP3, #available(iOS 10, *) {
            self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    convenience init(_ hex8: UInt32, displayP3: Bool = false) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        if displayP3, #available(iOS 10, *) {
            self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    convenience init?(_ hex: String, displayP3: Bool = false) {
        let str = hex.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        let len = str.count
        guard [3, 4, 6, 8].contains(len) else { return nil }
        
        let scanner = Scanner(string: str)
        var rgba: UInt32 = 0
        guard scanner.scanHexInt32(&rgba) else { return nil }
        
        let hasAlpha = (len % 4) == 0
        if len < 5 {
            let divisor = CGFloat(15)
            let red     = CGFloat((rgba & (hasAlpha ? 0xF000 : 0xF00)) >> (hasAlpha ? 12 :  8)) / divisor
            let green   = CGFloat((rgba & (hasAlpha ? 0x0F00 : 0x0F0)) >> (hasAlpha ?  8 :  4)) / divisor
            let blue    = CGFloat((rgba & (hasAlpha ? 0x00F0 : 0x00F)) >> (hasAlpha ?  4 :  0)) / divisor
            let alpha   = hasAlpha ? CGFloat(rgba & 0x000F) / divisor : 1.0
            if displayP3, #available(iOS 10, *) {
                self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
            } else {
                self.init(red: red, green: green, blue: blue, alpha: alpha)
            }
        } else {
            let divisor = CGFloat(255)
            let red     = CGFloat((rgba & (hasAlpha ? 0xFF000000 : 0xFF0000)) >> (hasAlpha ? 24 : 16)) / divisor
            let green   = CGFloat((rgba & (hasAlpha ? 0x00FF0000 : 0x00FF00)) >> (hasAlpha ? 16 :  8)) / divisor
            let blue    = CGFloat((rgba & (hasAlpha ? 0x0000FF00 : 0x0000FF)) >> (hasAlpha ?  8 :  0)) / divisor
            let alpha   = hasAlpha ? CGFloat(rgba & 0x000000FF) / divisor : 1.0
            if displayP3, #available(iOS 10, *) {
                self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
            } else {
                self.init(red: red, green: green, blue: blue, alpha: alpha)
            }
        }
    }
}


@available(iOS 8.2, *)
fileprivate extension UIFont.Weight {
    
    init(_ style: String) {
        switch style {
        case "ultraLight": self.init(rawValue: UIFont.Weight.medium.rawValue)
        case "thin": self.init(rawValue: UIFont.Weight.thin.rawValue)
        case "light": self.init(rawValue: UIFont.Weight.light.rawValue)
        case "medium": self.init(rawValue: UIFont.Weight.medium.rawValue)
        case "semibold": self.init(rawValue: UIFont.Weight.semibold.rawValue)
        case "bold": self.init(rawValue: UIFont.Weight.bold.rawValue)
        case "heavy": self.init(rawValue: UIFont.Weight.heavy.rawValue)
        case "black": self.init(rawValue: UIFont.Weight.black.rawValue)
        default: self.init(rawValue: UIFont.Weight.regular.rawValue)
        }
    }
}

fileprivate extension NSValue {
    
    convenience init?(_ string: String) {
        self.init()
    }
}

public extension ThemeManager {
    public class func getValue<ValueType>(for keyPath: String) -> ValueType? {
        guard let info = shared.currentTheme?.info else { return nil }
        guard let value = info.value(forKeyPath: keyPath) as? ValueType else { return nil }
        return value
    }
}

public extension ThemeManager {
    
    public class func string(_ keyPath: String) -> String? {

//        guard let string = getValue(for: keyPath) as? String else { return nil }
        guard let info = shared.currentTheme?.info else { return nil }
        guard let value = info.value(forKeyPath: keyPath) as? String else { return nil }
        return value
    }
    
    public class func number(_ keyPath: String) -> NSNumber? {
        
        guard let info = shared.currentTheme?.info else { return nil }
        guard let value = info.value(forKeyPath: keyPath) as? NSNumber else { return nil }
        return value
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
    
    public class func image(_ keyPath: String) -> UIImage? {

        guard let imageName = string(keyPath) else { return nil }
        if let filePath = shared.currentTheme?.path.URL?.appendingPathComponent(imageName).path {
            guard let image = UIImage(contentsOfFile: filePath) else { return nil }
            return image
        } else {
            print("SwiftTheme WARNING: Not found image name at main bundle: \(imageName)")
            guard let image = UIImage(named: imageName) else { return nil }
            return image
        }
    }

    /// get UIFont from a style
    /// support style of (font.name,font.size,font.weight)
    /// - Parameter keyPath: the key path of style
    /// - Returns: Optional(UIFont)
    public class func font(_ keyPath: String) -> UIFont? {
        guard let string = string(keyPath) else { return nil }
        let values = string.split(separator: ".")
        guard values.count == 3 else { return nil }
        let name = String(values.first ?? "")
        let size = CGFloat((String(values[1]) as NSString).floatValue)
        if (name.count <= 0 || ["system", "*"].contains(name)) {
            if #available(iOS 8.2, *) {
                return UIFont.systemFont(ofSize: size, weight: UIFont.Weight(String(values.last ?? "")))
            } else {
                return UIFont.systemFont(ofSize: size)
            }
        } else {
            return UIFont.init(name: name, size: size)
        }
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
    public convenience init(_ keyPath: String) {
        self.init { return ThemeManager.image(keyPath) }
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
