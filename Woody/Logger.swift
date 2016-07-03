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
    
    public let destinationURL = FileUtility.defaultLoggingDestination(createIntermediateDirectoriesIfNeeded: true)
    public let fileSizeLimit: Int? = 10 * 1024 * 1024
    public let loggingQueue: dispatch_queue_t = dispatch_queue_create("com.codezerker.woody.logging", DISPATCH_QUEUE_SERIAL)
  }
  
  private let configuration: Configuration
  private let fileHandle: NSFileHandle
  
  public init?(configuration: Configuration) {
    guard let destinationURL = configuration.destinationURL,
          let fileHandle = try? NSFileHandle(forWritingToURL: destinationURL) else {
      return nil
    }
    
    self.fileHandle = fileHandle
    self.configuration = configuration
  }
  
  public func log(logable: Logable) {
    dispatch_async(configuration.loggingQueue) {
      let logging = self.loggingPrefix + logable.loggingRepresentation + self.loggingSuffi
      guard let loggingData = logging.dataUsingEncoding(NSUTF8StringEncoding) else {
        return
      }
      
      self.fileHandle.seekToEndOfFile()
      self.fileHandle.writeData(loggingData)
      self.fileHandle.synchronizeFile()
    }
  }
}

private extension Logger {
  
  var loggingPrefix: String {
    return "[Woody] (\(NSDate())): "
  }
  
  var loggingSuffix: String {
    return "\n"
  }
}
