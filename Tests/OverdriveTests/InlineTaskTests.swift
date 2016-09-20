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
        
        XCTAssert(task.state == .initialized, "Task state should be Initialized")
    }
    
    func testInlineTaskExecution() {
        let finishExpecation = expectation(description: "Inline task finish expectation")
        
        let task = InlineTask {
            print("do work")
        }
        
        task.onValue {_ in
            finishExpecation.fulfill()
        }
        
        TaskQueue(qos: .default).addTask(task)
        
        waitForExpectations(timeout: 0.2) { handlerError in
            print(handlerError)
        }
    }
}
