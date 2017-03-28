//
//  TaskObserverTests.swift
//  Overdrive
//
//  Created by Said Sikira on 7/7/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest

@testable import Overdrive

class TaskObserverTests: XCTestCase {
    
    var startExecutionExpectation: XCTestExpectation?
    var finishExecutionExpectation: XCTestExpectation?
    var willFinishExecutionExpectation: XCTestExpectation?
    
    override func setUp() {
        startExecutionExpectation = expectation(description: "Task started expectation")
        willFinishExecutionExpectation = expectation(description: "Task will finish expectation")
        finishExecutionExpectation = expectation(description: "Task finished expectation")
    }
    
    func testTaskObserver() {
        let task = anyTask(withResult: .value(1))
        let queue = TaskQueue()
        
        task.add(observer: self)
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}

extension TaskObserverTests: TaskObserver {
    func taskDidStartExecution<T>(_ task: Task<T>) {
        startExecutionExpectation?.fulfill()
    }
    
    func taskDidFinishExecution<T>(_ task: Task<T>) {
        finishExecutionExpectation?.fulfill()
    }

    func taskWillFinishExecution<T>(_ task: Task<T>) {
        willFinishExecutionExpectation?.fulfill()
        XCTAssert(task.isExecuting)
    }
}
