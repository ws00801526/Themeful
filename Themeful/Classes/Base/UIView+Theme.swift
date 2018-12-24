//  UIView+Theme.swift
//  Pods
//
//  Created by  XMFraker on 2018/12/2
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      UIView_Theme
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

extension UIView : ThemefulCompatible { }

public typealias ThemeStateValuePicker = ThemeMultiPicker<UInt>

public extension Themeful where Base: NSObjectProtocol {
    
    typealias ValuePicker = () -> Any?
    public func setPicker(_ picker: ThemePicker?, for selector: Selector) -> Self {
        self.pickers[selector] = picker
        if let _ = picker { self.performThemePicker(selector: selector, picker: picker) }
        return self
    }
    
    public func picker(of selector: Selector) -> ThemePicker? {
        return self.pickers[selector]
    }
}

public extension Themeful where Base: UIView {
    
    public func setBackgroundColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UIView.backgroundColor)) }
    
    public func setTintColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UIView.tintColor)) }

    public func setHidden(_ keyPath: String) -> Self { return setPicker(ThemeBoolPicker(keyPath), for: #selector(setter: UIView.isHidden)) }
    
    public func setAlpha(_ keyPath: String) -> Self { return setPicker(ThemeFloatPicker(keyPath), for: #selector(setter: UIView.alpha)) }
}

public extension Themeful where Base : UIImageView {
    
    public func setImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), for: #selector(setter: UIImageView.image)) }

    public func setHighlightImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), for: #selector(setter: UIImageView.highlightedImage)) }
}

public extension Themeful where Base : UISegmentedControl {
    
    typealias ThemeSegmentValuePicker = ThemeMultiPicker<Int>
    
    public func setTitle(_ keyPath: String, forSegmentAt index: Int) -> Self {

        let selector = #selector(UISegmentedControl.setTitle(_:forSegmentAt:))
        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.string(keyPath) }, for: index) }
        else { multiPicker?.setPicker(v: { return ThemeManager.string(keyPath) }, for: index) }
        return setPicker(multiPicker, for: selector)
    }

    public func setImage(_ keyPath: String, forSegmentAt index: Int) -> Self {
        
        let selector = #selector(UISegmentedControl.setImage(_:forSegmentAt:))
        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: index) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: index) }
        return setPicker(multiPicker, for: selector)
    }

//    public func setWidth(_ keyPath: String, forSegmentAt index: Int) -> Self {
//
//        let selector = #selector(UISegmentedControl.setWidth(_:forSegmentAt:))
//        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
//        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.number(keyPath)?.floatValue }, for: index) }
//        else { multiPicker?.setPicker(v: { return ThemeManager.number(keyPath)?.floatValue }, for: index) }
//        return setPicker(multiPicker, forSelector: selector)
//    }
    
//    public func setEnabled(_ keyPath: String, forSegmentAt index: Int) -> Self {
//
//        let selector = #selector(UISegmentedControl.setEnabled(_:forSegmentAt:))
//        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
//        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.number(keyPath)?.boolValue }, for: index) }
//        else { multiPicker?.setPicker(v: { return ThemeManager.number(keyPath)?.boolValue }, for: index) }
//        return setPicker(multiPicker, forSelector: selector)
//    }
}

public extension Themeful where Base: UIButton {
    
    public func setTitle(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setTitle(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.string(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.string(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
    
    public func setTitleColor(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setTitleColor(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }

    public func setTitleShadowColor(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setTitleShadowColor(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
    
    public func setImage(_ keyPath: String, for state: UIControl.State) -> Self {
     
        let selector = #selector(UIButton.setImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
    
    public func setBackgroundImage(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setBackgroundImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
}

public extension Themeful where Base : UILabel {
    
    public func setText(_ keyPath: String) -> Self { return setPicker(ThemeStringPicker(keyPath), for: #selector(setter: UILabel.text)) }
    
    public func setTextColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UILabel.textColor)) }

    public func setHighlightedTextColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UILabel.highlightedTextColor)) }

    public func setShadowColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UILabel.shadowColor)) }
    
    public func setFont(_ keyPath: String) -> Self { return setPicker(ThemeFontPicker(keyPath), for: #selector(setter: UILabel.font)) }
    
    public func setTextAlignment(_ keyPath: String) -> Self { return setPicker(ThemeIntPicker(keyPath), for: #selector(setter: UILabel.textAlignment)) }
    
    public func setLineBreakMode(_ keyPath: String) -> Self { return setPicker(ThemeIntPicker(keyPath), for: #selector(setter: UILabel.lineBreakMode)) }
}

public extension Themeful where Base : UITabBar {
    
    @available(iOS 7.0, *)
    public func setBarTintColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UITabBar.barTintColor)) }

    @available(iOS 6.0, *)
    public func setShadowImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), for: #selector(setter: UITabBar.shadowImage)) }

    @available(iOS 5.0, *)
    public func setBackgroundImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), for: #selector(setter: UITabBar.backgroundImage)) }

    @available(iOS 5.0, *)
    public func setBackgroundColorImage(_ keyPath: String) -> Self {
        let picker = ThemePicker(v: { return ThemeManager.colorImage(keyPath) })
        return setPicker(picker, for:  #selector(setter: UITabBar.backgroundImage))
    }
    
    @available(iOS 5.0, *)
    public func setSelectionIndicatorImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), for: #selector(setter: UITabBar.selectionIndicatorImage)) }

}

public extension Themeful where Base : UINavigationBar {
        
    public func setBarTintColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), for: #selector(setter: UINavigationBar.barTintColor)) }

    public func setShadowImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), for: #selector(setter: UINavigationBar.shadowImage)) }

    public func setTitleTextAttributes(_ keyPath: String) -> Self { return setPicker(ThemeAttirbutesPicker(keyPath), for: #selector(setter: UINavigationBar.titleTextAttributes)) }
    
    public func setBackgroundImage(_ keyPath: String, for barPosition: UIBarPosition = .any, barMetrics: UIBarMetrics = .default) -> Self {
        let picker = ThemeBackgroundImagePicker(keyPath)
        picker.barMetrics = barMetrics
        picker.barPosition = barPosition
        return setPicker(picker, for: #selector(UINavigationBar.setBackgroundImage(_:for:barMetrics:)))
    }
    
    public func setBackgroundColorImage(_ keyPath: String, for barPosition: UIBarPosition = .any, barMetrics: UIBarMetrics = .default) -> Self {
        let picker = ThemeBackgroundImagePicker(colorKeyPath: keyPath)
        picker.barMetrics = barMetrics
        picker.barPosition = barPosition
        return setPicker(picker, for: #selector(UINavigationBar.setBackgroundImage(_:for:barMetrics:)))
    }
    
    @available(iOS 11.0, *)
    public func setPrefersLargeTitles(_ keyPath: String) -> Self { return setPicker(ThemeBoolPicker(keyPath), for: #selector(setter: UINavigationBar.prefersLargeTitles)) }
}


public extension Themeful where Base : UISearchBar {
    
    public func setBackgroundImage(_ keyPath: String, for barPosition: UIBarPosition = .any, barMetrics: UIBarMetrics = .default) -> Self {
        let picker = ThemeBackgroundImagePicker(keyPath)
        picker.barPosition = barPosition
        picker.barMetrics = barMetrics
        return setPicker(picker, for: #selector(UISearchBar.setBackgroundImage(_:for:barMetrics:)))
    }
    
    public typealias ThemeIconImagePicker = ThemeMultiPicker<String>
    public func setImage(_ keyPath: String, for icon: UISearchBar.Icon = .search, state: UIControl.State = .normal) -> Self {

        let key = "\(icon)_\(state)"
        let selector = #selector(UISearchBar.setImage(_:for:state:))
        var multiPicker = self.picker(of: selector) as? ThemeIconImagePicker
        if multiPicker == nil { multiPicker = ThemeIconImagePicker(v: { return ThemeManager.image(keyPath) }, for: key) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: key) }
        return setPicker(multiPicker, for: selector)
    }
    
    public func setSearchFieldBackgroundImage(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UISearchBar.setSearchFieldBackgroundImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
    
    public func setScopeBarButtonTitleTextAttributes(_ keyPath: String, for state: UIControl.State) -> Self {
        let selector = #selector(UISearchBar.setScopeBarButtonBackgroundImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.textAttributes(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.textAttributes(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
    
    public func setScopeBarButtonBackgroundImage(_ keyPath: String, for state: UIControl.State) -> Self {
        let selector = #selector(UISearchBar.setScopeBarButtonBackgroundImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, for: selector)
    }
    
//    setScopeBarButtonTitleTextAttributes
    
//    setScopeBarButtonBackgroundImage
}
