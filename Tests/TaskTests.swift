//
//  Tests.swift
//  Tests
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class SimpleTask: Task<Int> {
    override func run() {
        finish(.Value(10))
    }
}

class FailableTask: Task<Int> {
    enum TaskError: ErrorType {
        case TaskFail
    }
    
    override func run() {
        finish(.Error(TaskError.TaskFail))
    }
}

class TaskTests: XCTestCase {
    
    let queue = TaskQueue()
    
    func testTaskState() {
        let task = SimpleTask()
        let expectation = expectationWithDescription("Task state test")
        XCTAssert(task.state == .Initialized, "Task state should be: Initialized")
        
        queue.addTask(task)
        
        task.onComplete { value in
            XCTAssert(task.state == .Finished, "Task state should be: Finished")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.1) { handlerError in
            print(handlerError)
        }
    }
    
    func testCompletionBlocks() {
        let task = SimpleTask()
        
        task
            .onComplete { _ in }
            .onError { _ in }
        
        XCTAssert(task.onCompleteBlock != nil, "onComplete block should be set")
        XCTAssert(task.onErrorBlock != nil, "onError block should be set")
    }
    
    func testOnCompleteBlock() {
        let task = SimpleTask()
        let expectation = expectationWithDescription("Task result value expecation")
        
        task.onComplete { value in
            XCTAssert(value == 10, "Task result value should be 10")
            expectation.fulfill()
        }
        
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.1) { handlerError in
            print(handlerError)
        }
    }
    
    func testOnErrorBlock() {
        let task = FailableTask()
        let expectation = expectationWithDescription("Task result error expecation")
        
        task
            .onError { error in
                expectation.fulfill()
            }.onComplete { _ in
                XCTFail("onComplete block should not be executed")
        }
        
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.1) { handlerError in
            print(handlerError)
        }
    }
}
