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
        self.removeThemeNotification()
    }
    
    @objc fileprivate func updateTheme() {
        
        UIView.animate(withDuration: ThemeManager.duration) {
            self.pickers.forEach { [weak self] in self?.performThemePicker(selector: $0.key, picker: $0.value) }
        }

//        self.pickers.forEach { [weak self] in
//            let key = $0.key
//            let value = $0.value
//            UIView.animate(withDuration: ThemeManager.duration, animations: {
//                self?.performThemePicker(selector: key, picker: value)
//            })
//        }
    }
}

public protocol ThemefulCompatible: NSObjectProtocol {
    associatedtype CompatibleType
    var tf: CompatibleType { get }
}

fileprivate var TFKey: Int = 101
public extension ThemefulCompatible where Self: NSObject {

    public var tf: Themeful<Self> {
        if let tf = objc_getAssociatedObject(self, &TFKey) as? Themeful<Self> { return tf }
        let tf = Themeful(self)
        objc_setAssociatedObject(self, &TFKey, tf, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return tf
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
        
//        guard let picker = picker                  else { return }
        guard self.base.responds(to: selector)     else { return }
        let methodSignature = self.base.method(for: selector)
        
        switch picker {
        case let picker as ThemeFloatPicker:
            let setValue = unsafeBitCast(methodSignature, to: setCGFloatValueIMP.self)
            setValue(self.base, selector, CGFloat(picker.floatValue()))
        case let picker as ThemeBoolPicker:
            let setBool = unsafeBitCast(methodSignature, to: setValueIMP.self)
            setBool(self.base, selector, picker.boolValue())
        case let picker as ThemeIntPicker:
            let setBool = unsafeBitCast(methodSignature, to: setIntValueIMP.self)
            setBool(self.base, selector, picker.intValue())
        case let picker as ThemeSegmentValuePicker:
            let setValueIndex = unsafeBitCast(methodSignature, to: setValueForIndexIMP.self)
            picker.valuePickers.forEach { if let value = $0.value() { setValueIndex(self.base, selector, value, $0.key) } }
        case let picker as ThemeStateValuePicker:
            let setValueState = unsafeBitCast(methodSignature, to: setValueForStateIMP.self)
            picker.valuePickers.forEach { if let value = $0.value() { setValueState(self.base, selector, value, UIControl.State(rawValue: $0.key)) } }
        case let picker as ThemeStatusBarStylePicker:
            let setStatusBarStyle = unsafeBitCast(methodSignature, to: setStatusBarStyleValueIMP.self)
            setStatusBarStyle(self.base, selector, picker.style, picker.animated)
        case _ as ThemeFontPicker: fallthrough
        case _ as ThemeColorPicker: fallthrough
        case _ as ThemeImagePicker: fallthrough
        default: self.base.perform(selector, with: picker?.valuePicker())
        }
    }
    
    fileprivate typealias setValueIMP               = @convention(c) (NSObject, Selector, Any)                        -> Void
    fileprivate typealias setIntValueIMP            = @convention(c) (NSObject, Selector, Int)                        -> Void
    fileprivate typealias setBoolValueIMP           = @convention(c) (NSObject, Selector, Bool)                       -> Void
    fileprivate typealias setFloatValueIMP          = @convention(c) (NSObject, Selector, Float)                      -> Void
    fileprivate typealias setCGColorValueIMP        = @convention(c) (NSObject, Selector, CGColor)                    -> Void
    fileprivate typealias setCGFloatValueIMP        = @convention(c) (NSObject, Selector, CGFloat)                    -> Void
    fileprivate typealias setValueForIndexIMP       = @convention(c) (NSObject, Selector, Any, Int)                   -> Void
    fileprivate typealias setValueForStateIMP       = @convention(c) (NSObject, Selector, Any, UIControl.State)       -> Void
    fileprivate typealias setStatusBarStyleValueIMP = @convention(c) (NSObject, Selector, UIStatusBarStyle, Bool)     -> Void
}
