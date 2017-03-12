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
    let queue = TaskQueue(qos: .default)
    
    var startExecutionExpectation: XCTestExpectation?
    var finishExecutionExpectation: XCTestExpectation?
    var willFinishExecutionExpectation: XCTestExpectation?

	
    override func setUp() {
        startExecutionExpectation = expectation(description: "Task added to the queue expectation")
        finishExecutionExpectation = expectation(description: "Task finished expectation")
        willFinishExecutionExpectation = expectation(description: "Task will finish expectation")
    }
    
    func testDelegate() {
        let task = anyTask(withResult: .value(1))
        task.name = "SimpleTask"
        
        queue.delegate = self
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}

extension TaskQueueDelegateTests: TaskQueueDelegate {
    func didAdd<T>(task: Task<T>, toQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, .initialized)
        XCTAssertEqual(task.name, "SimpleTask")
        startExecutionExpectation?.fulfill()
    }
    
    func didFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, .finished)
        XCTAssertEqual(task.name, "SimpleTask")
        finishExecutionExpectation?.fulfill()
    }

    func willFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, .executing)
        XCTAssertEqual(task.name, "SimpleTask")
        willFinishExecutionExpectation?.fulfill()
    }

    func didRetry<T>(_ task: Task<T>, inQueue queue: TaskQueue) {
        XCTFail("Should retry should not be called")
    }
}
