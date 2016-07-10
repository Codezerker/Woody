//
//  WoodyTests.swift
//  WoodyTests
//
//  Created by Yan Li on 7/4/16.
//  Copyright © 2016 Codezerker. All rights reserved.
//

import XCTest
@testable import Woody

class WoodyTests: XCTestCase {
  
  var logger: Logger?
  
  override func setUp() {
    super.setUp()
    
    var configuration = Logger.Configuration()
    configuration.timestampProvider = Timestamper()
    
    logger = Logger(configuration: configuration)
    logger?.clear()
  }
  
  override func tearDown() {
    super.tearDown()
    logger?.clear()
  }
  
  func testInitialization() {
    XCTAssertNotNil(logger)
  }
  
  func testLogging() {
    let examples = [
      Example(value1: 1, value2: 2),
      Example(value1: 3, value2: 4),
      Example(value1: 5, value2: 6),
    ]
    
    for example in examples {
      logger?.log(logable: example)
    }
    
    let expectation = expectationWithDescription("read")
    logger?.read { result in
      let expectedLog =
          "===== [Woody] <timestamp> =====" + "\n" +
          "Example -> value1 : 1" + "\n" +
          "        -> value2 : 2" + "\n" +
          "\n" +
          "===== [Woody] <timestamp> =====" + "\n" +
          "Example -> value1 : 3" + "\n" +
          "        -> value2 : 4" + "\n" +
          "\n" +
          "===== [Woody] <timestamp> =====" + "\n" +
          "Example -> value1 : 5" + "\n" +
          "        -> value2 : 6" + "\n" +
          "\n"
      XCTAssertEqual(result, expectedLog)
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testLoggingItems() {
    let examples: [Logable] = [
      Example(value1: 1, value2: 2),
      Example(value1: 3, value2: 4),
      Example(value1: 5, value2: 6),
    ]
    
    logger?.log(logables: examples)
    let expectation = expectationWithDescription("read")
    logger?.read { result in
      let expectedLog =
          "===== [Woody] <timestamp> =====" + "\n" +
          "[1/3] Example -> value1 : 1" + "\n" +
          "        -> value2 : 2" + "\n" +
          "[2/3] Example -> value1 : 3" + "\n" +
          "        -> value2 : 4" + "\n" +
          "[3/3] Example -> value1 : 5" + "\n" +
          "        -> value2 : 6" + "\n" +
          "\n"
      XCTAssertEqual(result, expectedLog)
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testClearAndLog() {
    let noise = "Noise - Noise - Noise"
    logger?.log(logable: noise)
    logger?.clear()
    
    let example = Example(value1: 555, value2: 999)
    logger?.log(logable: example)
    
    let expectation = expectationWithDescription("read")
    logger?.read { result in
      let expectedLog =
          "===== [Woody] <timestamp> =====" + "\n" +
          "Example -> value1 : 555" + "\n" +
          "        -> value2 : 999" + "\n" +
          "\n"
      XCTAssertEqual(result, expectedLog)
      expectation.fulfill()
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }
}


struct Timestamper: TimestampProvider {
  
  func timestampForDate(date: NSDate) -> String {
    return "<timestamp>"
  }
}


struct Example: Logable {
  
  let value1: Int
  let value2: Int
  
  var loggingRepresentation: String {
    return "Example -> value1 : \(value1)" + "\n" +
           "        -> value2 : \(value2)"
  }
}
