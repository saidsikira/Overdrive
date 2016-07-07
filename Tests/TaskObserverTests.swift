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
        startExecutionExpecation = expectationWithDescription("Task started expecatation")
        finishExecutionExpecation = expectationWithDescription("Task finished expecation")
    }
    
    func testTaskObserver() {
        let task = SimpleTask()
        let queue = TaskQueue()
        
        task.addObserver(self)
        
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.2) { handlerError in
            print(handlerError)
        }
    }
}

extension TaskObserverTests: TaskObserver {
    func taskDidStartExecution<T>(task: Task<T>) {
        startExecutionExpecation?.fulfill()
    }
    
    func taskDidFinishExecution<T>(task: Task<T>) {
        finishExecutionExpecation?.fulfill()
    }
}
