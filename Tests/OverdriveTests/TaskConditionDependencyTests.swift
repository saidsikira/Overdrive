//
//  TaskConditionDependencyTests.swift
//  Overdrive
//
//  Created by Said Sikira on 7/6/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest

@testable import Overdrive

// MARK: - DependencyTestCondition

class DependencyTestCondition: TaskCondition {
    func dependencies<T>(forTask task: Task<T>) -> [Operation] {
        return [
            anyTask(withResult: .value(1))
        ]
    }
    
    func evaluate<T>(forTask task: Task<T>, evaluationBlock: ((TaskConditionResult) -> Void)) {
        evaluationBlock(.satisfied)
    }
}

// MARK: - Tests

class TaskConditionDependencyTests: XCTestCase {
    
    var addExpecation: XCTestExpectation?
    var finishExpecation: XCTestExpectation?
    
    func testConditionWithDelegate() {
        addExpecation = expectation(description: "Task added to the queue expecation")
        finishExpecation = expectation(description: "Task finished with execution expecation")
        
        let queue = TaskQueue()
        queue.delegate = self
        
        let task = anyTask(withResult: .value(1))
        let condition = DependencyTestCondition()
        
        task.add(condition: condition)
        
        XCTAssertEqual(task.conditions.count, 1, "Task condition count should be equal to 1")
        XCTAssertEqual(task.dependencies.count, 0, "Task dependency count should be equal to 0")
        
        queue.add(task:task)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - TaskQueueDelegate implementation

extension TaskConditionDependencyTests: TaskQueueDelegate {
    
    func didAdd<T>(task: Task<T>, toQueue queue: TaskQueue) {
        XCTAssertEqual(task.dependencies.count, 1, "Task dependency count should be equal to 1")
        addExpecation?.fulfill()
    }
    
    func didFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        finishExpecation?.fulfill()
    }
}
