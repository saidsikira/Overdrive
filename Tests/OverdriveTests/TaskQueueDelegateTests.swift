//
//  TaskQueueDelegateTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/24/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
import TestSupport

@testable import Overdrive

class TaskQueueDelegateTests: XCTestCase {
    let queue = TaskQueue(qos: .default)
    
    var startExecutionExpecation: XCTestExpectation?
    var finishExecutionExpecation: XCTestExpectation?
    
    override func setUp() {
        startExecutionExpecation = expectation(description: "Task added to the queue expecatation")
        finishExecutionExpecation = expectation(description: "Task finished expecation")
    }
    
    func testDelegate() {
        let task = SimpleTask()
        task.name = "SimpleTask"
        
        queue.delegate = self
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.2) { handlerError in
            print(handlerError)
        }
    }
}

extension TaskQueueDelegateTests: TaskQueueDelegate {
    func didAdd<T>(task: Task<T>, toQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, State.initialized)
        XCTAssertEqual(task.name, "SimpleTask")
        startExecutionExpecation?.fulfill()
    }
    
    func didFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, State.finished)
        XCTAssertEqual(task.name, "SimpleTask")
        finishExecutionExpecation?.fulfill()
    }
    
    func didRetry<T>(_ task: Task<T>, inQueue queue: TaskQueue) {
        XCTFail("Should retry should not be called")
    }
}
