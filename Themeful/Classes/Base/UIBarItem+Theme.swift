//  UIBarItem+Theme.swift
//  Pods
//
//  Created by  XMFraker on 2018/12/11
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      UIBarItem_Theme
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

extension UIBarItem: ThemefulCompatible {}
extension UINavigationItem: ThemefulCompatible {}

public extension Themeful where Base : UINavigationItem {
    
    public func setTitle(_ keyPath: String) -> Self { return setPicker(ThemeStringPicker(keyPath), for: #selector(setter: UINavigationItem.title)) }
    
    public func setPrompt(_ keyPath: String) -> Self { return setPicker(ThemeStringPicker(keyPath), for: #selector(setter: UINavigationItem.prompt)) }
}

public extension Themeful where Base : UIBarItem {
    
    public func setTitle(_ keyPath: String) -> Self { return setPicker(ThemeStringPicker(keyPath), for: #selector(setter: UIBarItem.title)) }
    
    public func setImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath, rendering: .alwaysOriginal), for: #selector(setter: UIBarItem.image)) }
    
    @available(iOS 5.0, *)
    public func setLandscapeImagePhone(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath, rendering: .alwaysOriginal), for: #selector(setter: UIBarItem.landscapeImagePhone)) }
    
    @available(iOS 11.0, *)
    public func setLargeContentSizeImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath, rendering: .alwaysOriginal), for: #selector(setter: UIBarItem.largeContentSizeImage)) }
    
    @available(iOS 5.0, *)
    public func setTitleTextAttributes(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIBarItem.setTitleTextAttributes(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.textAttributes(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.textAttributes(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
}

public extension Themeful where Base: UITabBarItem {
    
    public func setBadgeValue(_ keyPath: String) -> Self { return setPicker(ThemeStringPicker(keyPath), for: #selector(setter: UITabBarItem.badgeValue)) }
    
    @available(iOS 10.0, *)
    public func setBadgeColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UITabBarItem.badgeColor)) }
    
    @available(iOS 7.0, *)
    public func setSelectedImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath, rendering: .alwaysOriginal), for: #selector(setter: UITabBarItem.selectedImage)) }
    
    @available(iOS 10.0, *)
    public func setBadgeTextAttributes(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UITabBarItem.setBadgeTextAttributes(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.textAttributes(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.textAttributes(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
}
