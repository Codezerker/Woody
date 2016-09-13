//
//  Utilities.swift
//  Woody
//
//  Created by Yan Li on 7/3/16.
//  Copyright © 2016 Codezerker. All rights reserved.
//

import Foundation

internal struct FileUtility {
  
  private static let fileManager = FileManager.default
  
  static func defaultLoggingDestination(createIntermediateDirectoriesIfNeeded createIfNeeded: Bool) -> NSURL? {
    let documentURL = try? fileManager.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: createIfNeeded) as NSURL
    let loggingDir = documentURL?.appendingPathComponent(loggingDirName, isDirectory: true)
    let loggingFile = loggingDir?.appendingPathComponent(loggingFileName, isDirectory: false)
    
    guard let dirURL = loggingDir,
          let fileURL = loggingFile else {
      return nil
    }
    
    if createIfNeeded && !fileURL.isWritable {
      do {
        try fileManager.createDirectory(at: dirURL,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
        try reset(file: fileURL as NSURL)
      } catch {
        return nil
      }
    }
    
    return loggingFile as NSURL?
  }
  
  static func clearLog(fileURL: NSURL) {
    _ = try? reset(file: fileURL)
  }
}

private extension FileUtility {
  
  static let loggingDirName = "com.codezerker.Woody"
  static let loggingFileName = "log.txt"
  
  static func reset(file fileURL: NSURL) throws {
    try NSData().write(to: fileURL as URL, options: [])
  }
}

private extension URL {
  
  var isWritable: Bool {
    do {
      return try resourceValues(forKeys: [.isWritableKey]).isWritable ?? false
    } catch {
      return false
    }
  }
}
