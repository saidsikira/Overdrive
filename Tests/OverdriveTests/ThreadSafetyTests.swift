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
        let task = anyTask(withResult: .value(1))
        
        let customQueueExpecation = expectation(description: "Value on custom dispatch queue")
        let backgroundQueueExpecation = expectation(description: "Value on background queue")
        
        let customDispatchQueue = DispatchQueue(label: "io.overdrive.queue", attributes: [])
        let backgroundDispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        task.onValue { value in
            customDispatchQueue.async {
                XCTAssertEqual(value, 1, "Incorrect value on custom queue")
                customQueueExpecation.fulfill()
            }
            
            backgroundDispatchQueue.async {
                XCTAssertEqual(value, 1, "Incorrect value on background queue")
                backgroundQueueExpecation.fulfill()
            }
        }
        
        TaskQueue(qos: .default).add(task: task)
        
        waitForExpectations(timeout: 0.4, handler: nil)
    }
    
    func testExecutionOnCustomQueue() {
        let backgroundQueueExpecation = expectation(description: "Execution on background queue")
        
        let backgroundDispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        let task = anyTask(withResult: .value(1))
        
        task.onValue { value in
            backgroundDispatchQueue.async {
                XCTAssertEqual(value, 1, "Incorrect value on background queue")
                backgroundQueueExpecation.fulfill()
            }
        }
        
        let queue = TaskQueue(queue: DispatchQueue.global(qos: .background))
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.4, handler: nil)
    }
}
