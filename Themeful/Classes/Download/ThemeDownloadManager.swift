//  ThemeDownloadManager.swift
//  Pods
//
//  Created by  XMFraker on 2018/12/17
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      ThemeDownloadManager
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit

public typealias ThemefulCompletedHandler        = (_ theme: Theme?, _ error: ThemefulError?) -> Void
public typealias ThemefulUnzipProgressHandler    = (_ loaded: Int64, _ total: Int64) -> Void
public typealias ThemefulDownloadProgressHandler = (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalbytesExpectedToWrite: Int64) -> Void

@objc public enum ThemefulDownloadStatus: Int {
    
    case new
    case downloading
    case downloaded
    case suspended
}

public protocol ThemefulDownloadProtocol {
    var remoteURL: URL? { get set }
    var name: String { get set }
    var config: NSDictionary? { get set }
}

public enum ThemefulError: Error {
    
    public enum DownloadThemeFailureReason {
        case unknown
        case downloading(URLSessionDownloadTask?)
        case downloaded(URLSessionDownloadTask?)
    }
    
    public enum UnzipThemeFailureReason {
        case incorrectPassword
        case contentNotReadable
        case fileNotWritable
        case unknown
    }
    
    case downloadThemeFailed(reason: DownloadThemeFailureReason)
    case unzipThemeFailed(reason: UnzipThemeFailureReason)
    
    public var localizedDescription: String {

        switch self {
        case .downloadThemeFailed(let reason):
            if case let .downloaded(task) = reason { return "Themeful ERROR: the task \(String(describing: task ?? nil)) is already downloaded" }
            else if case let .downloading(task) = reason { return "Themeful ERROR: the task \(String(describing: task ?? nil)) is downloading now" }
            else { return "Themeful ERROR: unknown reason while download theme" }
        case .unzipThemeFailed(let reason):
            switch reason {
            case .incorrectPassword: return "Themeful ERROR: the zip file's password is incorrect"
            case .contentNotReadable: return "Themeful ERROR: the zip file cannot be opened"
            case .fileNotWritable: return "Themeful ERROR: the zip file cannot be writted"
            default: return "Themeful ERROR: unknown reason while unzip file"
            }
        }
    }
}

public protocol ThemeDownloadDelegate {
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionTask,
                         status: ThemefulDownloadStatus) -> Void
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionTask,
                         didCompleted theme: Theme?,
                         error: ThemefulError?) -> Void
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionDownloadTask,
                         didWriteData bytesWritten: Int64,
                         totalBytesWritten: Int64,
                         totalBytesExpectedWrite: Int64) -> Void
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         downloadTask task: URLSessionDownloadTask,
                         didResumeAtOffset fileOffset: Int64,
                         expectedTotalBytes: Int64) -> Void
    
    func downloadManager(_ manager: ThemeDownloadManager,
                         unzipProgress loaded: Int64,
                         total: Int64) -> Void
}

public extension Theme {
    
    public var isExists: Bool {
        switch self.path {
        case .sandbox(let URL): return Theme.isExists(at: URL)
        default:
            if let _ = Bundle.main.url(forResource: self.name, withExtension: JSONFileExtension) { return true }
            if let _ = Bundle.main.url(forResource: self.name, withExtension: PlistFileExtension) { return true }
            return false
        }
    }
    
    public class var downloadedThemes: [Theme] {
        let contents = try? FileManager.default.contentsOfDirectory(at: themeDir(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        guard let subPaths = contents else { return [] }
        return subPaths.map { Theme($0.lastPathComponent, path: .sandbox($0)) }.filter({ $0.isExists })
    }
    
    public class func isExists(of name: String) -> Bool {
        let URL = themeDir(name)
        let theme = Theme(name, path: .sandbox(URL))
        return theme.isExists
    }
    
    public class func downloadedTheme(of name: String) -> Theme? {
        let URL = themeDir(name)
        let theme = Theme(name, path: .sandbox(URL))
        guard theme.isExists else { return nil }
        return theme
    }
}

public class ThemeDownloadManager: NSObject {
    
    public static let shared = ThemeDownloadManager()
    fileprivate lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
    }()
    
    fileprivate let taskCache = ThemeThreadSafeStack<String, URLSessionDownloadTask>()
    fileprivate let wrapperCahce = ThemeThreadSafeStack<Int, ThemeDownloadDelegateWrapper>()
}


public extension ThemeDownloadManager {
    
    func clearThemeCache(with name: String) -> Bool {
        
        // should not remove current using theme
        if ThemeManager.shared.currentTheme?.name == name { return false }
        let URL = Theme.themeDir(name)
        if FileManager.default.fileExists(at: URL), let _ = try? FileManager.default.removeItem(at: URL) {
            return true
        } else {
            return false
        }
    }
}

public extension ThemeDownloadManager {
    
    func downloadTheme(with info: ThemefulDownloadProtocol,
                       downloadProgress: ThemefulDownloadProgressHandler? = nil,
                       unzipProgress: ThemefulUnzipProgressHandler? = nil,
                       handler: ThemefulCompletedHandler? = nil) -> URLSessionDownloadTask? {
        
        var status: ThemefulDownloadStatus = .new
        let task = downloadTask(with: info, status: &status)
        
        switch status {
        case .downloaded:
            let theme = Theme.downloadedThemes.first(where: { $0.name == info.name })
            if let handler = handler { handler(theme, .downloadThemeFailed(reason: .downloaded(task))) }
            return task
        case .downloading:
            if let handler = handler { handler(nil, .downloadThemeFailed(reason: .downloading(task))) }
            return task
        default: break
        }
        
        guard let _ = task else { return nil }
        let wrapper = ThemeDownloadDelegateWrapper(self, info: info, downloadProgress: downloadProgress, unzipProgress: unzipProgress, handler: handler)
        wrapperCahce.push(wrapper, for: task!.taskIdentifier)
        return task
    }
    
    func downloadTheme(with info: ThemefulDownloadProtocol, delegate: ThemeDownloadDelegate? = nil) -> URLSessionDownloadTask? {
        
        var status: ThemefulDownloadStatus = .new
        let task = downloadTask(with: info, status: &status)
        
        if case .downloaded = status {
            let theme = Theme.downloadedThemes.first(where: { $0.name == info.name })
            delegate?.downloadManager(self, downloadTask: task, didCompleted: theme, error: .downloadThemeFailed(reason: .downloaded(task)))
            return task
        } else if case .downloading = status {
            delegate?.downloadManager(self, downloadTask: task, didCompleted: nil, error: .downloadThemeFailed(reason: .downloading(task)))
            return task
        }
        
        guard let _ = task else { return nil }
        let wrapper = ThemeDownloadDelegateWrapper(self, info: info, delegate: delegate)
        wrapperCahce.push(wrapper, for: task!.taskIdentifier)
        return task
    }
}

extension ThemeDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        guard let wrapper = wrapperCahce[downloadTask.taskIdentifier] else { return }
        wrapper.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let wrapper = wrapperCahce[downloadTask.taskIdentifier] else { return }
        wrapper.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let _ = error else { return }

        // clear delegate & task while some error happened, other condition will be cleared when (download & unzip) finished
        guard let wrapper = wrapperCahce[task.taskIdentifier] else { return }
        wrapper.urlSession(session, task: task, didCompleteWithError: error)
        let _ = clearCache(with: task)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let wrapper = wrapperCahce[downloadTask.taskIdentifier] else { return }
        guard let path = try? wrapper.moveZip(at: location) else {
            
            let _ = clearCache(with: downloadTask)
            return
        }
        wrapper.unzipFile(at: path, task: downloadTask) { [weak self] (_, task) in let _ = self?.clearCache(with: task) }
    }
}

fileprivate class ThemeThreadSafeStack<K,V>  where K: Hashable {
    
    private let lock = NSLock()
    private var infos: [K: V] = [:]
    
    fileprivate var count: Int {
        lock.lock()
        let value = infos.count
        lock.unlock()
        return value
    }
    
    func push(_ value: V, for key: K) -> Void {
        lock.lock()
        infos[key] = value
        lock.unlock()
    }
    
    func pop(_ key: K) -> V? {
        lock.lock()
        let value = infos.removeValue(forKey: key)
        lock.unlock()
        return value
    }
    
    subscript(key: K) -> V? {
        lock.lock()
        let value = infos[key]
        lock.unlock()
        return value
    }
}

fileprivate extension ThemeDownloadManager {
    
    func clearCache(with task: URLSessionTask) -> Bool {
        guard let key = task.originalRequest?.url?.absoluteString else { return false }
        let _ = taskCache.pop(key)
        let _ = wrapperCahce.pop(task.taskIdentifier)
        
        // invalidate session while task.count is zero in case of break some retain cycle
        if taskCache.count <= 0 {
            session.invalidateAndCancel()
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        }
        return true
    }
}

fileprivate extension ThemeDownloadManager {
    
    /// Create & Store & Start
    func downloadTask(with URL: URL) -> URLSessionDownloadTask {
        let task = session.downloadTask(with: URL)
        taskCache.push(task, for: URL.absoluteString)
        task.resume()
        return task
    }
    
    func downloadTask(with info: ThemefulDownloadProtocol, status: inout ThemefulDownloadStatus) -> URLSessionDownloadTask? {
        
        guard let remoteURL = info.remoteURL else { return nil }
        guard let name = Theme.themeName(of: info) else { return nil }
        
        // check is theme downloaded
        guard Theme.isExists(at: Theme.themeDir(name)) == false else {
            status = .downloaded
            return nil
        }
        
        // check is theme downloading
        if let task = taskCache[remoteURL.absoluteString] {
            status = .downloading
            return task
        }
        
        return downloadTask(with: remoteURL)
    }
}
