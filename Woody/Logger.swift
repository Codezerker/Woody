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
    public var loggingQueue: dispatch_queue_t = dispatch_queue_create("com.codezerker.woody.logging", DISPATCH_QUEUE_SERIAL)
    public var timestampProvider: TimestampProvider? = DefaultTimestampProvider()
    
    public init() {
      // ...
    }
  }
  
  public let configuration: Configuration
  private let fileHandle: NSFileHandle
  
  public init?(configuration: Configuration) {
    guard let destinationURL = configuration.destinationURL,
          let fileHandle = try? NSFileHandle(forUpdatingURL: destinationURL) else {
      return nil
    }
    
    self.fileHandle = fileHandle
    self.configuration = configuration
  }
  
  public func log(logable logable: Logable) {
    dispatch_async(configuration.loggingQueue) {
      let log = self.loggingPrefix + logable.loggingRepresentation + self.loggingSuffix
      self.prepareToLog()
      self.writeLogToFile(log)
      self.finalizeLogging()
    }
  }
  
  public func log(logables logables: [Logable]) {
    dispatch_async(configuration.loggingQueue) { 
      self.prepareToLog()
      self.writeLogToFile(self.loggingPrefix)
      for (index, logable) in logables.enumerate() {
        self.writeLogToFile(logables.itemLoggingPrefix(atIndex: index)
          + logable.loggingRepresentation
          + logables.itemLoggingSuffix)
      }
      self.writeLogToFile(logables.itemLoggingSuffix)
      self.finalizeLogging()
    }
  }
  
  public func clear() {
    dispatch_async(configuration.loggingQueue) {
      FileUtility.clearLog(self.configuration.destinationURL!)
    }
  }
  
  public func read(completion: String? -> Void) {
    dispatch_async(configuration.loggingQueue) {
      let fileHandle = try? NSFileHandle(forReadingFromURL: self.configuration.destinationURL!)
      let data = fileHandle?.readDataToEndOfFile()
      let string = String(data: data!, encoding: NSUTF8StringEncoding)
      dispatch_async(dispatch_get_main_queue()) {
        completion(string)
      }
    }
  }
}

private extension Logger {
  
  var loggingPrefix: String {
    if let timestamp = configuration.timestampProvider?.timestampForDate(NSDate()) {
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
    guard let logData = logString.dataUsingEncoding(NSUTF8StringEncoding) else {
      return
    }
    fileHandle.writeData(logData)
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
