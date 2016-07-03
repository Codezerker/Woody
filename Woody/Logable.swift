//
//  Logable.swift
//  Woody
//
//  Created by Yan Li on 7/3/16.
//  Copyright © 2016 Codezerker. All rights reserved.
//

import Foundation

public protocol Logable {
  
  var loggingRepresentation: String { get }
}

extension String: Logable {
  
  public var loggingRepresentation: String {
    return self
  }
}
