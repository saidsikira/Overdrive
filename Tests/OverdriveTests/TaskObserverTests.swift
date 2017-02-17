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
    
    var startExecutionExpection: XCTestExpectation?
    var finishExecutionExpection: XCTestExpectation?
    var willFinishExecutionExpection: XCTestExpectation?
    
    override func setUp() {
        startExecutionExpection = expectation(description: "Task started expectation")
        willFinishExecutionExpection = expectation(description: "Task will finish expection")
        finishExecutionExpection = expectation(description: "Task finished expection")
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
        startExecutionExpection?.fulfill()
    }
    
    func taskDidFinishExecution<T>(_ task: Task<T>) {
        finishExecutionExpection?.fulfill()
    }

    func taskWillFinishExecution<T>(_ task: Task<T>) {
        willFinishExecutionExpection?.fulfill()
        XCTAssert(task.isExecuting)
    }
}
