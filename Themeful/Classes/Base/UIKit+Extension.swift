//  UIKit+Extension.swift
//  Pods
//
//  Created by  XMFraker on 2019/1/14
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      UIKit_Extension
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

internal extension UIColor {
    
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

internal extension UIImage {
    
    internal class func image(with color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage? {
        
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

@available(iOS 8.2, *)
internal extension UIFont.Weight {
    
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

internal extension UIFont {
    
    internal class func font(with string: String) -> UIFont? {
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

