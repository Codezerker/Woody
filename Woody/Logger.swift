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
  
  public func log(logable: Logable) {
    dispatch_async(configuration.loggingQueue) {
      let logging = self.loggingPrefix + logable.loggingRepresentation + self.loggingSuffix
      guard let loggingData = logging.dataUsingEncoding(NSUTF8StringEncoding) else {
        return
      }
      
      self.fileHandle.seekToEndOfFile()
      self.fileHandle.writeData(loggingData)
      self.fileHandle.synchronizeFile()
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
}
