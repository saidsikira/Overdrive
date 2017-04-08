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
    
    enum CustomError: Error {
        case error
    }
    
    func testComputedProperties() {
        let result: Result = .value(10)
        
        XCTAssertEqual(result.value, 10)
        XCTAssertNil(result.error)
    }
    
    func testMap() {
        let result: Result = .value(10)
        let stringResult = result.map { String($0) }
        
        XCTAssertEqual(stringResult.value, "10")
    }
    
    func testMapWithError() {
        let result: Result<Int> = .error(TaskError.fail(""))
        let stringResult = result.map { String($0) }
        
        XCTAssertNotNil(stringResult.error)
    }
    
    func testMapError() {
        let result: Result<Int> = .error(TaskError.fail(""))
        let mapped = result.mapError { _ in return CustomError.error }
        
        XCTAssertNil(mapped.value)
        XCTAssertEqual((mapped.error as? CustomError), .error)
    }
    
    func testMapErrorWithValue() {
        let result: Result<Int> = .value(10)
        let mapped = result.mapError { _ in return CustomError.error }
        
        XCTAssertNotNil(mapped.value)
        XCTAssertEqual(mapped.value, 10)
    }
    
    func testFlatMap() {
        let result: Result = .value(10)
        let stringResult = result.flatMap { return Result("\($0)") }
        
        XCTAssertEqual(stringResult.value, "10")
        XCTAssertNil(stringResult.error)
    }
    
    func testFlatMapError() {
        let result: Result<Int> = .error(TaskError.fail(""))
        let mapped = result.flatMapError { _ in return .error(CustomError.error) }
        
        XCTAssertNotNil(mapped.error)
        XCTAssertEqual((mapped.error as? CustomError), .error)
    }
}
