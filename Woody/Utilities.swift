//
//  Utilities.swift
//  Woody
//
//  Created by Yan Li on 7/3/16.
//  Copyright © 2016 Codezerker. All rights reserved.
//

import Foundation

internal struct FileUtility {
  
  private static let fileManager = NSFileManager.defaultManager()
  
  static func defaultLoggingDestination(createIntermediateDirectoriesIfNeeded createIfNeeded: Bool) -> NSURL? {
    let documentURL = try? fileManager.URLForDirectory(.DocumentDirectory,
                                                       inDomain: .UserDomainMask,
                                                       appropriateForURL: nil,
                                                       create: createIfNeeded)
    let loggingDir = documentURL?.URLByAppendingPathComponent(loggingDirName, isDirectory: true)
    let loggingFile = loggingDir?.URLByAppendingPathComponent(loggingFileName, isDirectory: false)
    
    guard let dirURL = loggingDir,
          let fileURL = loggingFile else {
      return nil
    }
    
    if createIfNeeded && !fileURL.isWritable {
      do {
        try fileManager.createDirectoryAtURL(dirURL,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
        try reset(file: fileURL)
      } catch {
        return nil
      }
    }
    
    return loggingFile
  }
  
  static func clearLog(fileURL: NSURL) {
    _ = try? reset(file: fileURL)
  }
}

private extension FileUtility {
  
  static let loggingDirName = "com.codezerker.Woody"
  static let loggingFileName = "log.txt"
  
  static func reset(file fileURL: NSURL) throws {
    try NSData().writeToURL(fileURL, options: [])
  }
}

private extension NSURL {
  
  var isWritable: Bool {
    var writable: AnyObject?
    _ = try? getResourceValue(&writable, forKey: NSURLIsWritableKey)
    
    guard let number = (writable as? NSNumber)?.boolValue else {
      return false
    }
    
    return number.boolValue
  }
}
