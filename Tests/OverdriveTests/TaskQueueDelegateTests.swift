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
    
    var startExecutionExpection: XCTestExpectation?
    var finishExecutionExpection: XCTestExpectation?
    var willFinishExecutionExpection: XCTestExpectation?

    override func setUp() {
        startExecutionExpection = expectation(description: "Task added to the queue expectation")
        finishExecutionExpection = expectation(description: "Task finished expection")
        willFinishExecutionExpection = expectation(description: "Task will finish expection")
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
        startExecutionExpection?.fulfill()
    }
    
    func didFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, .finished)
        XCTAssertEqual(task.name, "SimpleTask")
        finishExecutionExpection?.fulfill()
    }

    func willFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, .executing)
        XCTAssertEqual(task.name, "SimpleTask")
        willFinishExecutionExpection?.fulfill()
    }

    func didRetry<T>(_ task: Task<T>, inQueue queue: TaskQueue) {
        XCTFail("Should retry should not be called")
    }
}
