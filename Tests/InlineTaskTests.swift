//
//  InlineTaskTests.swift
//  Overdrive
//
//  Created by Said Sikira on 7/8/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class InlineTaskTests: XCTestCase {
    
    func testInlineTaskState() {
        let task = InlineTask {
        }
        
        XCTAssert(task.state == .Initialized, "Task state should be Initialized")
    }
    
    func testInlineTaskExecution() {
        let finishExpecation = expectationWithDescription("Inline task finish expectation")
        
        let task = InlineTask {
            print("do work")
        }
        
        task.onComplete {
            value in
            finishExpecation.fulfill()
        }
        
        TaskQueue.main.addTask(task)
        
        waitForExpectationsWithTimeout(0.2) { handlerError in
            print(handlerError)
        }
    }
}
