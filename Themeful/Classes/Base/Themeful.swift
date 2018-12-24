//  Themeful.swift
//  Pods
//
//  Created by  XMFraker on 2018/12/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Themeful
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

public final class Themeful<Base> where Base: NSObject {
    
    internal typealias ThemePickers = [Selector : ThemePicker]
    internal var pickers: ThemePickers = [:]

    public let base: Base
    public init(_ base: Base) {
        self.base = base
        self.setupThemeNotification()
    }
    
    deinit {
        #if DEBUG
        print("\(self) will deinit")
        #endif
        self.removeThemeNotification()
    }
    
    @objc fileprivate func updateTheme() {
        
        UIView.animate(withDuration: ThemeManager.duration) {
            self.pickers.forEach { [weak self] in self?.performThemePicker(selector: $0.key, picker: $0.value) }
        }
    }
}

public protocol ThemefulCompatible: NSObjectProtocol {
    associatedtype CompatibleType
    var theme: CompatibleType { get }
}

fileprivate var TFKey: Int = 101
public extension ThemefulCompatible where Self: NSObject {

    public var theme: Themeful<Self> {
        if let theme = objc_getAssociatedObject(self, &TFKey) as? Themeful<Self> { return theme }
        let theme = Themeful(self)
        objc_setAssociatedObject(self, &TFKey, theme, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return theme
    }
}

fileprivate extension Themeful {
    
    fileprivate func setupThemeNotification() {
        let center = NotificationCenter.default
        if #available(iOS 9.0, *) { // iOS9 later we dont need to remove notification, perferred to using this method
            center.addObserver(self, selector: #selector(Themeful.updateTheme), name: ThemeDidUpdateNotification, object: nil)
        } else {
            center.addObserver(forName: ThemeDidUpdateNotification, object: nil, queue: nil) { [weak self] _ in self?.updateTheme() }
        }
    }
    
    fileprivate func removeThemeNotification() {
        NotificationCenter.default.removeObserver(self, name: ThemeDidUpdateNotification, object: nil)
    }
    
}


extension Themeful {
    
    func performThemePicker(selector: Selector, picker: ThemePicker?) {
        
        guard self.base.responds(to: selector)     else { return }
        let methodSignature = self.base.method(for: selector)
        
        switch picker {
        case let picker as ThemeIntPicker:
            let setInt = unsafeBitCast(methodSignature, to: setIntValueIMP.self)
            setInt(self.base, selector, picker.intValue())
        case let picker as ThemeBoolPicker:
            let setBool = unsafeBitCast(methodSignature, to: setBoolValueIMP.self)
            setBool(self.base, selector, picker.boolValue())
        case let picker as ThemeFloatPicker:
            let setValue = unsafeBitCast(methodSignature, to: setCGFloatValueIMP.self)
            setValue(self.base, selector, CGFloat(picker.floatValue()))
        case let picker as ThemeSegmentValuePicker:
            let setValueIndex = unsafeBitCast(methodSignature, to: setValueForIndexIMP.self)
            picker.valuePickers.forEach { setValueIndex(self.base, selector, $0.value(), $0.key) }
        case let picker as ThemeStateValuePicker:
            let setValueState = unsafeBitCast(methodSignature, to: setValueForStateIMP.self)
            picker.valuePickers.forEach { setValueState(self.base, selector, $0.value(), UIControl.State(rawValue: $0.key)) }
        case let picker as ThemeBackgroundImagePicker:
            let setBackgroundImage = unsafeBitCast(methodSignature, to: setBackgroundImageIMP.self)
            setBackgroundImage(self.base, selector, picker.rawValue, picker.barPosition, picker.barMetrics)
        case let picker as ThemeIconImagePicker:
            
            let setIconImage = unsafeBitCast(methodSignature, to: setIconImageIMP.self)
            picker.valuePickers.forEach {
                let icon = UISearchBar.Icon(rawValue: Int($0.key.split(separator: "_").first!) ?? 0)
                let state = UIControl.State(rawValue: UInt($0.key.split(separator: "_").last!) ?? 0)
                setIconImage(self.base, selector, $0.value() as? UIImage, icon ?? .search, state)
            }
        case _ as ThemeFontPicker: fallthrough
        case _ as ThemeColorPicker: fallthrough
        case _ as ThemeImagePicker: fallthrough
        default: self.base.perform(selector, with: picker?.valuePicker())
        }
    }
    
    fileprivate typealias setValueIMP               = @convention(c) (NSObject, Selector, Any)                        -> Void
    fileprivate typealias setIntValueIMP            = @convention(c) (NSObject, Selector, Int)                        -> Void
    fileprivate typealias setBoolValueIMP           = @convention(c) (NSObject, Selector, Bool)                       -> Void
    fileprivate typealias setCGColorValueIMP        = @convention(c) (NSObject, Selector, CGColor)                    -> Void
    fileprivate typealias setCGFloatValueIMP        = @convention(c) (NSObject, Selector, CGFloat)                    -> Void
    fileprivate typealias setValueForIndexIMP       = @convention(c) (NSObject, Selector, Any?, Int)                  -> Void
    /// using for set UIControl value, such as, setTitle:for, setTitleColor:for
    fileprivate typealias setValueForStateIMP       = @convention(c) (NSObject, Selector, Any?, UIControl.State)      -> Void
    fileprivate typealias setStatusBarStyleValueIMP = @convention(c) (NSObject, Selector, UIStatusBarStyle, Bool)     -> Void
    fileprivate typealias setBackgroundImageIMP     = @convention(c) (NSObject, Selector, UIImage?, UIBarPosition, UIBarMetrics)           -> Void
    fileprivate typealias setIconImageIMP           = @convention(c) (NSObject, Selector, UIImage?, UISearchBar.Icon, UIControl.State)     -> Void
}
