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
    let queue = TaskQueue(qos: .Default)
    
    override func setUp() {
        queue.delegate = self
    }
    
    func testDelegate() {
        let task = SimpleTask()
        task.name = "SimpleTask"
        
        queue.addTask(task)
    }
}

extension TaskQueueDelegateTests: TaskQueueDelegate {
    func didAdd<T>(task task: Task<T>, toQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, State.Initialized)
        XCTAssertEqual(task.name, "SimpleTask")
    }
    
    func didFinish<T>(task task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssertEqual(task.state, State.Finished)
        XCTAssertEqual(task.name, "SimpleTask")
    }
    
    func didRetry<T>(task task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssert(false, "Should retry should not be called")
    }
}
