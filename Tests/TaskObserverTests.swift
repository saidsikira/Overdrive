//
//  TaskObserverTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class TestObserver: TaskObserver {
    func taskDidStartExecution<T>(task: Task<T>) {
        XCTAssert(task.state == .Executing, "Task state should be executing")
    }
    
    func taskDidFinishExecution<T>(task: Task<T>) {
        XCTAssert(task.state == .Finished, "Task state should be finished")
    }
}

class TaskObserverTests: XCTestCase {
    
    let queue = TaskQueue(qos: .Default)
    
    func testTaskObserver() {
        let task = SimpleTask()
        task.name = "Simple task"
        
        task.addObserver(TestObserver())
        
        queue.addTask(task)
    }
}
