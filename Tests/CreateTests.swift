//
//  CreateTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

enum TaskCreateError: ErrorType {
    case Fail
}

class CreateTests: XCTestCase {
    
    /// Tests `create(_:)` method with returned .Value(T)
    func testTaskCreateValue() {
        let expecation = expectationWithDescription("Task create with .Value(T) return")
        
        let someTask = Task<Int>.create {
            return .Value(1)
        }
        
        someTask
            .onValue {
                value in
                if value == 1 {
                    expecation.fulfill()
                }
            }.onError {
                error in
                XCTAssert(false, "onError block should not be executed")
        }
        
        TaskQueue.main.addTask(someTask)
        
        waitForExpectationsWithTimeout(0.2) { handlerError in
            print(handlerError)
        }
    }
    
    /// Tests `create(_:)` method with returned .Error(ErrorType)
    func testTaskCreateError() {
        let expectation = expectationWithDescription("Task create with .Error(ErrorType) return")
        
        let someTask = Task<Int>.create {
            return .Error(TaskCreateError.Fail)
        }
        
        someTask
            .onError {
                error in
                if error is TaskCreateError {
                    expectation.fulfill()
                } else {
                    XCTAssert(false, "Wrong error type returned")
                }
            }.onValue {
                value in
                XCTAssert(false, "onValue block should not be executed")
        }
        
        TaskQueue.main.addTask(someTask)
        
        waitForExpectationsWithTimeout(0.2) { handlerError in
            print(handlerError)
        }
    }
}
