//
//  Logger.swift
//  Woody
//
//  Created by Yan Li on 7/3/16.
//  Copyright © 2016 Codezerker. All rights reserved.
//

import Foundation

public struct Logger {
  
  public struct Configuration {
    
    public var destinationURL = FileUtility.defaultLoggingDestination(createIntermediateDirectoriesIfNeeded: true)
    public var fileSizeLimit: Int? = 10 * 1024 * 1024
    public var loggingQueue = DispatchQueue(label: "com.codezerker.woody.logging")
    public var timestampProvider: TimestampProvider? = DefaultTimestampProvider()
    
    public init() {
      // ...
    }
  }
  
  public let configuration: Configuration
  fileprivate let fileHandle: FileHandle
  
  public init?(configuration: Configuration) {
    guard let destinationURL = configuration.destinationURL,
          let fileHandle = try? FileHandle(forUpdating: destinationURL as URL) else {
      return nil
    }
    
    self.fileHandle = fileHandle
    self.configuration = configuration
  }
  
  public func log(logable: Logable) {
    configuration.loggingQueue.async {
      let log = self.loggingPrefix + logable.loggingRepresentation + self.loggingSuffix
      self.prepareToLog()
      self.writeLogToFile(logString: log)
      self.finalizeLogging()
    }
  }
  
  public func log(logables: [Logable]) {
    configuration.loggingQueue.async {
      self.prepareToLog()
      self.writeLogToFile(logString: self.loggingPrefix)
      for (index, logable) in logables.enumerated() {
        self.writeLogToFile(logString: logables.itemLoggingPrefix(atIndex: index)
          + logable.loggingRepresentation
          + logables.itemLoggingSuffix)
      }
      self.writeLogToFile(logString: logables.itemLoggingSuffix)
      self.finalizeLogging()
    }
  }
  
  public func clear() {
    configuration.loggingQueue.async {
      FileUtility.clearLog(fileURL: self.configuration.destinationURL!)
    }
  }
  
  public func read(completion: @escaping (String?) -> Void) {
    configuration.loggingQueue.async {
      let fileHandle = try? FileHandle(forReadingFrom: self.configuration.destinationURL! as URL)
      let data = fileHandle?.readDataToEndOfFile()
      let string = String(data: data!, encoding: String.Encoding.utf8)
      DispatchQueue.main.async {
        completion(string)
      }
    }
  }
}

private extension Logger {
  
  var loggingPrefix: String {
    if let timestamp = configuration.timestampProvider?.timestampForDate(date: NSDate()) {
      return "===== [Woody] " + timestamp + " =====\n"
    } else {
      return "===== [Woody] =====\n"
    }
  }
  
  var loggingSuffix: String {
    return "\n\n"
  }
  
  func prepareToLog() {
    self.fileHandle.seekToEndOfFile()
  }
  
  func writeLogToFile(logString: String) {
    guard let logData = logString.data(using: String.Encoding.utf8) else {
      return
    }
    fileHandle.write(logData)
  }
  
  func finalizeLogging() {
    self.fileHandle.synchronizeFile()
  }
}

private extension Array {
  
  func itemLoggingPrefix(atIndex index: Int) -> String {
    return "[\(index + 1)/\(count)] "
  }
  
  var itemLoggingSuffix: String {
    return "\n"
  }
}
