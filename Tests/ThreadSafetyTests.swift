//
//  ThreadSafetyTests.swift
//  Overdrive
//
//  Created by Said Sikira on 7/17/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class ThreadSafetyTests: XCTestCase {
    
    func testResultOnDispatchQueue() {
        let task = SimpleTask()
        
        let customQueueExpecation = expectationWithDescription("Value on custom dispatch queue")
        let backgroundQueueExpecation = expectationWithDescription("Value on background queue")
        
        let customDispatchQueue = dispatch_queue_create("io.overdrive.queue", nil)
        let backgroundDispatchQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        task.onValue { value in
            Dispatch.async(customDispatchQueue) {
                XCTAssert(value == 10, "Incorrect value on custom queue")
                customQueueExpecation.fulfill()
            }
            
            Dispatch.async(backgroundDispatchQueue) {
                XCTAssert(value == 10, "Incorrect value on background queue")
                backgroundQueueExpecation.fulfill()
            }
        }
        
        TaskQueue.main.addTask(task)
        
        waitForExpectationsWithTimeout(0.4) { handlerError in
            print(handlerError)
        }
    }
    
    func testExecutionOnCustomQueue() {
        let backgroundQueueExpecation = expectationWithDescription("Execution on background queue")
        
        let backgroundDispatchQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        let task = SimpleTask()
        
        task.onValue { value in
            Dispatch.async(backgroundDispatchQueue) {
                XCTAssert(value == 10, "Incorrect value on background queue")
                backgroundQueueExpecation.fulfill()
            }
        }
        
        let queue = TaskQueue()
        queue.underlyingQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        queue.addTask(task)
        
        waitForExpectationsWithTimeout(0.4) { handlerError in
            print(handlerError)
        }
    }
}
