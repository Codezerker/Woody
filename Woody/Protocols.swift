//
//  Logable.swift
//  Woody
//
//  Created by Yan Li on 7/3/16.
//  Copyright © 2016 Codezerker. All rights reserved.
//

import Foundation

// MARK: - Logable

public protocol Logable {
  
  var loggingRepresentation: String { get }
}

extension String: Logable {
  
  public var loggingRepresentation: String {
    return self
  }
}


// MARK: - TimestampProvider

public protocol TimestampProvider {
  
  func timestampForDate(date: NSDate) -> String
}

extension TimestampProvider {
  
  public func timestampForDate(date: NSDate) -> String {
    return "\(date)"
  }
}

public struct DefaultTimestampProvider: TimestampProvider {}
