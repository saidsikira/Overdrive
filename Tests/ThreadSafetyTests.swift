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
        
        let customQueueExpecation = expectation(description: "Value on custom dispatch queue")
        let backgroundQueueExpecation = expectation(description: "Value on background queue")
        
        let customDispatchQueue = DispatchQueue(label: "io.overdrive.queue", attributes: [])
        let backgroundDispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        task.onValue { value in
            customDispatchQueue.async {
                XCTAssert(value == 10, "Incorrect value on custom queue")
                customQueueExpecation.fulfill()
            }
            
            backgroundDispatchQueue.async {
                XCTAssert(value == 10, "Incorrect value on background queue")
                backgroundQueueExpecation.fulfill()
            }
        }
        
        TaskQueue(qos: .default).addTask(task)
        
        waitForExpectations(timeout: 0.4) { handlerError in
            print(handlerError)
        }
    }
    
    func testExecutionOnCustomQueue() {
        let backgroundQueueExpecation = expectation(description: "Execution on background queue")
        
        let backgroundDispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        let task = SimpleTask()
        
        task.onValue { value in
            backgroundDispatchQueue.async {
                XCTAssert(value == 10, "Incorrect value on background queue")
                backgroundQueueExpecation.fulfill()
            }
        }
        
        let queue = TaskQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        queue.addTask(task)
        
        waitForExpectations(timeout: 0.4) { handlerError in
            print(handlerError)
        }
    }
}
