//
//  TaskQueueDelegateTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/24/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class TaskQueueDelegateTests: XCTestCase {
    let queue = TaskQueue(qos: .Default)
    
    var startExecutionExpecation: XCTestExpectation?
    var finishExecutionExpecation: XCTestExpectation?
    
    override func setUp() {
        startExecutionExpecation = expectationWithDescription("Task added to the queue expecatation")
        finishExecutionExpecation = expectationWithDescription("Task finished expecation")
    }
    
    func testDelegate() {
        let task = SimpleTask()
        task.name = "SimpleTask"
        
        queue.delegate = self
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.2) { handlerError in
            print(handlerError)
        }
    }
}

extension TaskQueueDelegateTests: TaskQueueDelegate {
    func didAdd<T>(task task: Task<T>, toQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, State.Initialized)
        XCTAssertEqual(task.name, "SimpleTask")
        startExecutionExpecation?.fulfill()
    }
    
    func didFinish<T>(task task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, State.Finished)
        XCTAssertEqual(task.name, "SimpleTask")
        finishExecutionExpecation?.fulfill()
    }
    
    func didRetry<T>(task task: Task<T>, inQueue queue: TaskQueue) {
        XCTFail("Should retry should not be called")
    }
}
