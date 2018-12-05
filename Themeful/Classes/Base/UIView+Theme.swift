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

public extension Themeful where Base: UIResponder {
    
    typealias ValuePicker = () -> Any?
    public func setPicker(_ picker: ThemePicker?, forSelector selector: Selector) -> Self {
        self.pickers[selector] = picker
        if let _ = picker { self.performThemePicker(selector: selector, picker: picker) }
        return self
    }
    
    public func picker(of selector: Selector) -> ThemePicker? {
        return self.pickers[selector]
    }
}

public extension Themeful where Base: UIView {
    
    public func setBackgroundColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), forSelector: #selector(setter: UIView.backgroundColor)) }
    
    public func setTintColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), forSelector: #selector(setter: UIView.tintColor)) }

    public func setHidden(_ keyPath: String) -> Self { return setPicker(ThemeBoolPicker(keyPath), forSelector: #selector(setter: UIView.isHidden)) }
    
    public func setAlpha(_ keyPath: String) -> Self { return setPicker(ThemeFloatPicker(keyPath), forSelector: #selector(setter: UIView.alpha)) }
}

public extension Themeful where Base : UIImageView {
    
    public func setImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), forSelector: #selector(setter: UIImageView.image)) }

    public func setHighlightImage(_ keyPath: String) -> Self { return setPicker(ThemeImagePicker(keyPath), forSelector: #selector(setter: UIImageView.highlightedImage)) }
}

public extension Themeful where Base : UISegmentedControl {
    
    typealias ThemeSegmentValuePicker = ThemeMultiPicker<Int>
    
    public func setTitle(_ keyPath: String, forSegmentAt index: Int) -> Self {

        let selector = #selector(UISegmentedControl.setTitle(_:forSegmentAt:))
        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.string(keyPath) }, for: index) }
        else { multiPicker?.setPicker(v: { return ThemeManager.string(keyPath) }, for: index) }
        return setPicker(multiPicker, forSelector: selector)
    }

    public func setImage(_ keyPath: String, forSegmentAt index: Int) -> Self {
        
        let selector = #selector(UISegmentedControl.setImage(_:forSegmentAt:))
        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: index) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: index) }
        return setPicker(multiPicker, forSelector: selector)
    }

    public func setWidth(_ keyPath: String, forSegmentAt index: Int) -> Self {
        
        let selector = #selector(UISegmentedControl.setWidth(_:forSegmentAt:))
        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.number(keyPath)?.floatValue }, for: index) }
        else { multiPicker?.setPicker(v: { return ThemeManager.number(keyPath)?.floatValue }, for: index) }
        return setPicker(multiPicker, forSelector: selector)
    }
    
    public func setEnabled(_ keyPath: String, forSegmentAt index: Int) -> Self {

        let selector = #selector(UISegmentedControl.setEnabled(_:forSegmentAt:))
        var multiPicker = self.picker(of: selector) as? ThemeSegmentValuePicker
        if multiPicker == nil { multiPicker = ThemeSegmentValuePicker.init(v: { return ThemeManager.number(keyPath)?.boolValue }, for: index) }
        else { multiPicker?.setPicker(v: { return ThemeManager.number(keyPath)?.boolValue }, for: index) }
        return setPicker(multiPicker, forSelector: selector)
    }
}

public extension Themeful where Base: UIButton {
    
    typealias ThemeStateValuePicker = ThemeMultiPicker<UInt>
    
    public func setTitle(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setTitle(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.string(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.string(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, forSelector: selector)
    }
    
    public func setTitleColor(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setTitleColor(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, forSelector: selector)
    }

    public func setTitleShadowColor(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setTitleShadowColor(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.color(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, forSelector: selector)
    }
    
    public func setImage(_ keyPath: String, for state: UIControl.State) -> Self {
     
        let selector = #selector(UIButton.setImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, forSelector: selector)
    }
    
    public func setBackgroundImage(_ keyPath: String, for state: UIControl.State) -> Self {
        
        let selector = #selector(UIButton.setBackgroundImage(_:for:))
        var multiPicker = self.picker(of: selector) as? ThemeStateValuePicker
        if multiPicker == nil { multiPicker = ThemeStateValuePicker.init(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        else { multiPicker?.setPicker(v: { return ThemeManager.image(keyPath) }, for: state.rawValue) }
        return setPicker(multiPicker, forSelector: selector)
    }
}

public extension Themeful where Base : UILabel {
    
    public func setText(_ keyPath: String) -> Self { return setPicker(ThemeStringPicker(keyPath), forSelector: #selector(setter: UILabel.text)) }
    
    public func setTextColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), forSelector: #selector(setter: UILabel.textColor)) }
    
    public func setShadowColor(_ keyPath: String) -> Self { return setPicker(ThemeColorPicker(keyPath), forSelector: #selector(setter: UILabel.shadowColor)) }
    
    public func setFont(_ keyPath: String) -> Self { return setPicker(ThemeFontPicker(keyPath), forSelector: #selector(setter: UILabel.font)) }
    
    public func setTextAlignment(_ keyPath: String) -> Self { return setPicker(ThemeIntPicker(keyPath), forSelector: #selector(setter: UILabel.textAlignment)) }
    
    public func setLineBreakMode(_ keyPath: String) -> Self { return setPicker(ThemeIntPicker(keyPath), forSelector: #selector(setter: UILabel.lineBreakMode)) }
}
