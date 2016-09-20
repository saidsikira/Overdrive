//
//  ResultTests.swift
//  Overdrive
//
//  Created by Said Sikira on 8/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class ResultTests: XCTestCase {
    func testComputedProperties() {
        let result: Result = .Value(10)
        
        XCTAssert(result.value == 10, "value should be equal to 10")
        XCTAssert(result.error == nil, "error should be nil")
    }
    
    func testMap() {
        let result: Result = .Value(10)
        let stringResult = result.map { String($0) }
        
        XCTAssert(stringResult.value == "10", "value after map should be equal to \"10\"")
    }
}
