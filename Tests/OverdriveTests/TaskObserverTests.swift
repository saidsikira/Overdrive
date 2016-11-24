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
    
    var startExecutionExpecation: XCTestExpectation?
    var finishExecutionExpecation: XCTestExpectation?
    
    override func setUp() {
        startExecutionExpecation = expectation(description: "Task started expecatation")
        finishExecutionExpecation = expectation(description: "Task finished expecation")
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
        startExecutionExpecation?.fulfill()
    }
    
    func taskDidFinishExecution<T>(_ task: Task<T>) {
        finishExecutionExpecation?.fulfill()
    }
}
