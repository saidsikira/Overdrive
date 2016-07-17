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
    
    let queue = TaskQueue(qos: .Default)
    
    func testIntializedState() {
        let task = SimpleTask()
        XCTAssert(task.state == .Initialized, "Task state should be: Initialized")
    }
    
    func testFinishedState() {
        let task = SimpleTask()
        let expectation = expectationWithDescription("Task finished state expecation")
        
        task.onValue { value in
            XCTAssert(task.state == .Finished, "Task state should be: Finished")
            expectation.fulfill()
        }
        
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.3) { handlerError in
            print(handlerError)
        }
    }
    
    func testOnValueCompletionBlockValue() {
        let task = SimpleTask()
        
        task
            .onValue { _ in }
            .onError { _ in }
        
        XCTAssert(task.onValueBlock != nil, "onValue block should be set")
    }
    
    func testOnErrorCompletionBlockValue() {
        let task = SimpleTask()
        
        task
            .onValue { _ in }
            .onError { _ in }
        
        
        XCTAssert(task.onErrorBlock != nil, "onError block should be set")
    }
    
    func testOnValueBlockExecution() {
        let task = SimpleTask()
        let expectation = expectationWithDescription("Task result value expecation")
        
        task.onValue { value in
            XCTAssert(value == 10, "Task result value should be 10")
            expectation.fulfill()
        }
        
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.1) { handlerError in
            print(handlerError)
        }
    }
    
    func testOnErrorBlockExecution() {
        let task = FailableTask()
        let expectation = expectationWithDescription("Task result error expecation")
        
        task
            .onError { error in
                expectation.fulfill()
            }.onValue { _ in
                XCTFail("onValue block should not be executed")
        }
        
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.1) { handlerError in
            print(handlerError)
        }
    }
}
