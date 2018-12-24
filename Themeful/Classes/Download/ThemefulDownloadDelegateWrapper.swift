//  ThemefulDownloadDelegateWrapper.swift
//  Pods
//
//  Created by  XMFraker on 2018/12/18
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      ThemefulDownloadDelegateWrapper
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

fileprivate let QueueName = "com.xmfraker.themeful.unzip.queue"
fileprivate let ThemefulBackgroundQueue = DispatchQueue.init(label: QueueName, qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
fileprivate let ThemeDir = Bundle.main.bundleIdentifier ?? "com.xmfraker.themeful"

class ThemeDownloadDelegateWrapper: NSObject {
    
    fileprivate var manager: ThemeDownloadManager
    fileprivate var info: ThemefulDownloadProtocol
    fileprivate var delegate: ThemeDownloadDelegate? = nil
    fileprivate var unzipProgress: ThemefulUnzipProgressHandler? = nil
    fileprivate var downloadProgress: ThemefulDownloadProgressHandler? = nil
    fileprivate var completedHandler: ThemefulCompletedHandler? = nil
    
    init(_ manager: ThemeDownloadManager,
         info: ThemefulDownloadProtocol,
         delegate: ThemeDownloadDelegate? = nil) {
        self.manager = manager
        self.info = info
        super.init()
    }
    
    init(_ manager: ThemeDownloadManager,
         info: ThemefulDownloadProtocol,
         downloadProgress: ThemefulDownloadProgressHandler? = nil,
         unzipProgress: ThemefulUnzipProgressHandler? = nil,
         handler: ThemefulCompletedHandler? = nil) {
        self.manager = manager
        self.info = info
        self.downloadProgress = downloadProgress
        self.unzipProgress = unzipProgress
        self.completedHandler = handler
        super.init()
    }
}

extension Theme {
    
    class func themeName(of info: ThemefulDownloadProtocol) -> String? {
        if info.name.count > 0 { return info.name }
        else if let name = info.remoteURL?.lastPathComponent, name.count > 0 { return name }
        else { return nil }
    }
    
    class func themeDir(_ subPath: String? = nil) -> URL {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return URL(fileURLWithPath: "\(subPath ?? "")") }
        if let subPath = subPath { return URL(fileURLWithPath: "\(path)/com.xmfraker.themeful/\(subPath)", isDirectory: false) }
        else { return URL(fileURLWithPath: "\(path)/com.xmfraker.themeful", isDirectory: false) }
    }
    
    class func isFileExists(at URL: URL, isDir: Bool = false) -> Bool {
        var isDirValue: ObjCBool = ObjCBool(false)
        if FileManager.default.fileExists(at: URL, isDirectory: &isDirValue) == false { return false }
        return isDirValue.boolValue == isDir
    }
        
    class func isExists(at URL: URL) -> Bool {
        if isFileExists(at: URL, isDir: true) {
            let jsonURL = URL.appendingPathComponent(URL.lastPathComponent).appendingPathExtension(JSONFileExtension)
            let plistURL = URL.appendingPathComponent(URL.lastPathComponent).appendingPathExtension(PlistFileExtension)
            return isFileExists(at: jsonURL, isDir: false) || isFileExists(at: plistURL, isDir: false)
        }
        return false
    }
}

extension ThemeDownloadDelegateWrapper {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let _ = error else { return }
        // just call back when download theme error
        let terror = ThemefulError.downloadThemeFailed(reason: .unknown)
        if let delegate = self.delegate {
            delegate.downloadManager(manager, downloadTask: task, didCompleted: nil, error: terror)
        } else if let handler = self.completedHandler {
            handler(nil, terror)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let delegate = self.delegate {
            delegate.downloadManager(manager, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedWrite: totalBytesExpectedToWrite)
        } else if let handler = self.downloadProgress {
            handler(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        if let delegate = self.delegate {
            delegate.downloadManager(manager, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        }
    }
}

extension FileManager {
    
    func fileExists(at URL: URL, isDirectory: UnsafeMutablePointer<ObjCBool>? = nil) -> Bool {
        if URL.isFileURL { return fileExists(atPath: URL.path, isDirectory: isDirectory) }
        else { return fileExists(atPath: URL.absoluteString, isDirectory: isDirectory) }
    }
    
    func renameFile(at URL: URL, with name: String, overwrite: Bool = false) -> Bool {
        
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

import SSZipArchive

fileprivate extension SSZipArchive {
    
    class func unzipFile(at srcURL: URL, to dstURL: URL, password: String? = nil, error: NSErrorPointer = nil, delegate: SSZipArchiveDelegate? = nil) -> Bool {

        let source = srcURL.isFileURL ? srcURL.path : srcURL.absoluteString;
        let destination = dstURL.isFileURL ? dstURL.path : dstURL.absoluteString;
        return SSZipArchive.unzipFile(atPath: source, toDestination: destination, preserveAttributes: true, overwrite: true, password: password, error: error, delegate: delegate)
    }
}

extension ThemeDownloadDelegateWrapper {
    
    func callBack(with task: URLSessionTask?, onQueue queue: DispatchQueue = DispatchQueue.main, theme: Theme? = nil, error: ThemefulError? = nil) {
        
        queue.async { [unowned self] in
            if let delegate = self.delegate {
                delegate.downloadManager(self.manager, downloadTask: task, didCompleted: theme, error: error)
            } else if let completedHandler = self.completedHandler {
                completedHandler(theme, error)
            }
        }
    }
}

extension ThemeDownloadDelegateWrapper {
    
    /// move and rename downloaded item to theme dir
    ///
    /// - Parameter srcURL: downloaded item source URL, should be ~/tmp/CFNetworkDownload_xxxxx.tmp
    /// - Returns: destination URL of the moved item. should be  ~/documents/com.xmfraker.themeful/xxx/xxx.zip
    /// - Throws: error if move item failed
    func moveZip(at srcURL: URL) throws -> URL {

        let dstURL = Theme.themeDir(info.name)
        var isDir: ObjCBool = ObjCBool(false)
        let isExists: Bool = FileManager.default.fileExists(at: dstURL, isDirectory: &isDir)
        if (isExists == false || isDir.boolValue == false) {
            // remove item if the theme dir is exists
            if isExists == true { try FileManager.default.removeItem(at: dstURL) }
            try FileManager.default.createDirectory(at: dstURL, withIntermediateDirectories: true, attributes: nil)
        }
        let destination = dstURL.appendingPathComponent(info.name).appendingPathExtension(ZIPFileExtension)
        if FileManager.default.fileExists(at: destination) { try FileManager.default.removeItem(at: destination) }
        try FileManager.default.moveItem(at: srcURL, to: destination)
        return destination
    }
    
    func unzipFile(at srcURL: URL, task: URLSessionDownloadTask, handler: @escaping (Bool, URLSessionTask) -> Void) -> Void {
        
        ThemefulBackgroundQueue.async { [unowned self] in
            
            let dstURL = srcURL.deletingLastPathComponent()
            let theme = Theme(self.info.name, path: .sandbox(dstURL))
            var errorPoint: NSError?
            var succ = SSZipArchive.unzipFile(at: srcURL, to: dstURL, error: &errorPoint, delegate: self)
            if succ {
                
                var isDirValue = ObjCBool(false)
                if (FileManager.default.fileExists(at: dstURL, isDirectory: &isDirValue) == false || isDirValue.boolValue == false) {
                    succ = FileManager.default.renameFile(at: srcURL.deletingPathExtension(), with: dstURL.lastPathComponent)
                }
                
                // create config file at unzip dir
                if let info = self.info.config, let contents = try? JSONSerialization.data(withJSONObject: info, options: []) {
                    let configURL = srcURL.deletingPathExtension().appendingPathExtension(JSONFileExtension)
                    let _ = FileManager.default.createFile(atPath: configURL.path, contents: contents, attributes: nil)
                }
            }
            
            var error: ThemefulError?
            if succ == false, let unzipError = errorPoint {
                if  let code = SSZipArchiveErrorCode(rawValue: unzipError.code) {
                    switch code {
                    case .failedOpenFileInZip:      fallthrough
                    case .failedOpenZipFile:        fallthrough
                    case .fileInfoNotLoadable:      error = .unzipThemeFailed(reason: .contentNotReadable)
                    case .invalidArguments:         error = .unzipThemeFailed(reason: .incorrectPassword)
                    case .failedToWriteFile:        error = .unzipThemeFailed(reason: .contentNotReadable)
                    default:                        error = .unzipThemeFailed(reason: .unknown)
                    }
                } else {
                    error = .unzipThemeFailed(reason: .unknown)
                }
            }
            
            self.callBack(with: task, theme: theme, error: error)
            DispatchQueue.main.async { handler(succ, task) }
        }
    }
}

extension ThemeDownloadDelegateWrapper: SSZipArchiveDelegate {
    
    func zipArchiveProgressEvent(_ loaded: UInt64, total: UInt64) {
        DispatchQueue.main.async { [unowned self] in
            if let delegate = self.delegate {
                delegate.downloadManager(self.manager, unzipProgress: Int64(loaded), total: Int64(total))
            } else if let progress = self.unzipProgress {
                progress(Int64(loaded), Int64(total))
            }
        }
    }
}

internal extension ThemeDownloadDelegate {
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionTask,
                         status: ThemefulDownloadStatus) -> Void {
        #if DEBUG
        print("Themeful WARNING: \(self) does not implements the method \(#function)")
        #endif
    }
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionTask?,
                         didCompleted theme: Theme?,
                         error: ThemefulError?) -> Void {
        #if DEBUG
        print("Themeful WARNING: \(self) does not implements the method \(#function)")
        #endif
    }
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionDownloadTask,
                         didWriteData bytesWritten: Int64,
                         totalBytesWritten: Int64,
                         totalBytesExpectedWrite: Int64) -> Void {
        #if DEBUG
        print("Themeful WARNING: \(self) does not implements the method \(#function)")
        #endif
    }
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionDownloadTask,
                         didResumeAtOffset fileOffset: Int64,
                         expectedTotalBytes: Int64) -> Void {
        #if DEBUG
        print("Themeful WARNING: \(self) does not implements the method \(#function)")
        #endif
    }
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         unzipProgress loaded: Int64,
                         total: Int64) -> Void {
        #if DEBUG
        print("Themeful WARNING: \(self) does not implements the method \(#function)")
        #endif
    }
}
