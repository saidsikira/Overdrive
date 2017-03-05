//
//  TaskQueueTests.swift
//  Overdrive
//
//  Created by Said Sikira on 2017-03-04.
//
//

import XCTest
@testable import Overdrive

class TaskQueueTests: XCTestCase {
    
    func testSuspendedState() {
        let queue = TaskQueue()
        let task = anyTask(withResult: .value(()))
    
        let finishExpectation = expectation(description: "Task finished with execution")
        
        task.onValue { finishExpectation.fulfill() }

        queue.isSuspended = true
        queue.add(task: task)
        queue.isSuspended = false
        
        waitForExpectations(timeout: 1)
    }
}
