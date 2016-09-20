//
//  TaskConditionDependencyTests.swift
//  Overdrive
//
//  Created by Said Sikira on 7/6/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
import TestSupport

@testable import Overdrive

class DependencyTestCondition: TaskCondition {
    func dependencies<T>(forTask task: Task<T>) -> [Operation] {
        return [SimpleTask()]
    }
    
    func evaluate<T>(forTask task: Task<T>, evaluationBlock: ((TaskConditionResult) -> Void)) {
        evaluationBlock(.satisfied)
    }
}

class TaskConditionDependencyTests: XCTestCase {
    
    var addExpecation: XCTestExpectation?
    var finishExpecation: XCTestExpectation?
    
    func testConditionWithDelegate() {
        addExpecation = expectation(description: "Task added to the queue expecation")
        finishExpecation = expectation(description: "Task finished with execution expecation")
        
        let queue = TaskQueue()
        queue.delegate = self
        
        let task = SimpleTask()
        let condition = DependencyTestCondition()
        
        task.add(condition: condition)
        
        XCTAssert(task.conditions.count == 1, "Task condition count should be equal to 1")
        XCTAssert(task.dependencies.count == 0, "Task dependency count should be equal to 0")
        
        queue.addTask(task)
        
        waitForExpectations(timeout: 1) { handlerError in
            print(handlerError)
        }
    }
}

extension TaskConditionDependencyTests: TaskQueueDelegate {
    func didAdd<T>(task: Task<T>, toQueue queue: TaskQueue) {
        XCTAssert(task.dependencies.count == 1, "Task dependency count should be equal to 1")
        addExpecation?.fulfill()
    }
    
    func didFinish<T>(task: Task<T>, inQueue queue: TaskQueue) {
        finishExpecation?.fulfill()
    }
    
    func didRetry<T>(_ task: Task<T>, inQueue queue: TaskQueue) {
        XCTAssert(false, "didRetry method should not be called")
    }
}
