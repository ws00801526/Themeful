//  Foundation+Extension.swift
//  Pods
//
//  Created by  XMFraker on 2019/1/14
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      Foundation_Extension
//  @version    <#class version#>
//  @abstract   <#class description#>

import Foundation

internal extension FileManager {
    
    internal func fileExists(at URL: URL, isDirectory: UnsafeMutablePointer<ObjCBool>? = nil) -> Bool {
        if URL.isFileURL { return fileExists(atPath: URL.path, isDirectory: isDirectory) }
        else { return fileExists(atPath: URL.absoluteString, isDirectory: isDirectory) }
    }
    
    internal func renameFile(at URL: URL, with name: String, overwrite: Bool = false) -> Bool {
        
        // file doesnot exists
        guard fileExists(at: URL) else { return false }
        
        let dstURL = URL.deletingLastPathComponent().appendingPathComponent(name)
        
        // remove exists dst if need overwrite
        if fileExists(at: URL) {
            if overwrite == false { return true }
            else { try? removeItem(at: dstURL) }
        }
        
        if let _ = try? moveItem(at: URL, to: dstURL) { return true }
        return false
    }
}

internal extension URL {
    
    internal var isJSONFile: Bool {
        return self.pathExtension == PlistFileExtension || self.pathExtension == JSONFileExtension
    }
    
    internal func JSON() -> NSDictionary? {
        
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

internal extension Array where Element: Hashable {
    
    internal func filterDuplicate() -> [Element] {
        if self.isEmpty { return [] }
        return Array(Set(self))
    }
}
