//
//  Filterable.swift
//  RaLog
//
//  Created by Rakuyo on 2020/09/01.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

// MARK: - Protocol

/// Provide the ability to filter logs by certain options
public protocol Filterable {
    
    /// Actually responsible for filtering the log.
    ///
    /// The default implementation:
    ///
    /// ```swift
    /// return filteredFiles.contains(log.fileName) || filteredFlags.contains(log.flag)
    /// ```
    ///
    /// - Parameter log: Log that judged whether they need to be filtered
    /// - Returns: Return `true` to prohibit printing
    static func filter(_ log: LogModel) -> Bool
    
    // MARK: - Filter Flag
    
    /// Used to store the `LogModel.Flag` that needs to be filtered.
    ///
    /// You can refer to the following implementation:
    ///
    /// ```swift
    /// public var filteredFlags: Set<LogModel.Flag> = [] // Do not filter any type of logs by default
    /// public var filteredFlags: Set<LogModel.Flag> = [LogModel.Flag("A")] // Filter Log of A tag by default
    /// ```
    static var filteredFlags: Set<LogModel.Flag> { get set }
    
    /// Filter a `LogModel.Flag`.
    ///
    /// - Parameter flag: `LogModel.Flag` filtered
    static func addFilter(flag: LogModel.Flag ...)
    
    /// Remove the filtering of a `LogModel.Flag`.
    ///
    /// - Parameter flag: `LogModel.Flag` whose filter is removed
    static func removeFilter(flag: LogModel.Flag ...)
    
    // MARK: - Filter File
    
    /// Used to store the filtered file name.
    ///
    /// See the `fileterCurrentFileLogs()` method for details.
    static var filteredFiles: Set<String> { get set }
    
    /// Used to filter all logs of the current page.
    ///
    /// - Parameter file: file path. In the default implementation, a parameter tag of `file = #file` is added.
    static func fileterCurrentFileLogs(_ file: String)
}

// MARK: - Default

public extension Filterable {
    
    @inline(__always)
    static func filter(_ log: LogModel) -> Bool {
        return filteredFiles.contains(log.fileName) || filteredFlags.contains(log.flag)
    }
}

// MARK: Flag

private var _filteredFlagsKey = "_raLog_filteredFlagsKey"

public extension Filterable {
    
    static var filteredFlags: Set<LogModel.Flag> {
        get {
            guard let kFilteredFlags = objc_getAssociatedObject(self, &_filteredFlagsKey) as? Set<LogModel.Flag> else {
                
                let kFilteredFlags = Set<LogModel.Flag>()
                objc_setAssociatedObject(self, &_filteredFlagsKey, kFilteredFlags, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return kFilteredFlags
            }
            
            return kFilteredFlags
        }
        set {
            objc_setAssociatedObject(self, &_filteredFlagsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static func addFilter(flag: LogModel.Flag ...) {
        flag.forEach { filteredFlags.insert($0) }
    }
    
    static func removeFilter(flag: LogModel.Flag ...) {
        flag.forEach { filteredFlags.remove($0) }
    }
}

// MARK: File

private var _filteredFilesKey = "_raLog_filteredFilesKey"

public extension Filterable {
    
    static var filteredFiles: Set<String> {
        get {
            
            guard let kFilteredFiles = objc_getAssociatedObject(self, &_filteredFilesKey) as? Set<String> else {
                
                let kFilteredFiles = Set<String>()
                objc_setAssociatedObject(self, &_filteredFilesKey, kFilteredFiles, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return kFilteredFiles
            }
            
            return kFilteredFiles
        }
        set {
            objc_setAssociatedObject(self, &_filteredFilesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static func fileterCurrentFileLogs(_ file: String = #file) {
        
        let fileName = LogModel("", fileName: file, methodName: "", line: 0, flag: LogModel.Flag(""), module: "").fileName
        filteredFiles.insert(fileName)
    }
}