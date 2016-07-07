//
//  TaskConditionTests.swift
//  Overdrive
//
//  Created by Said Sikira on 7/2/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class TaskConditionTests: XCTestCase {
    
    let queue = TaskQueue(qos: .Default)
    
    class FailedTestCondition: TaskCondition {
        func evaluate<T>(forTask task: Task<T>, evaluationBlock: (TaskConditionResult -> Void)) {
            evaluationBlock(.Failed(TaskCreateError.Fail))
        }
    }
    
    class SatisfiedTestCondition: TaskCondition {
        func evaluate<T>(forTask task: Task<T>, evaluationBlock: (TaskConditionResult -> Void)) {
            evaluationBlock(.Satisfied)
        }
    }
    
    /// Tests failed condition
    func testFailedCondition() {
        let task = SimpleTask()
        let condition = FailedTestCondition()
        task.addCondition(condition)
        
        XCTAssert(task.conditions.count == 1, "Task condition count is not 1")
        XCTAssert(task.conditionErrors.count == 0, "Task condition error count should be 0")
        
        let expectation = expectationWithDescription("Task failed condition expecation")
        
        task
            .onComplete { value in
                XCTAssert(false, "onComplete block should not be executed")
            }.onError { error in
                XCTAssert(task.conditionErrors.count == 1, "Condition error count should be 1")
                expectation.fulfill()
        }
        
        TaskQueue.main.addTask(task)
        
        waitForExpectationsWithTimeout(1) {
            handlerError in
            print(handlerError)
        }
    }
    
    ///Tests satisfied condition
    func testSatisfiedCondition() {
        let task = SimpleTask()
        let condition = SatisfiedTestCondition()
        task.addCondition(condition)
        
        XCTAssert(task.conditions.count == 1, "Task condition count is not 1")
        XCTAssert(task.conditionErrors.count == 0, "Task condition error count should be 0")
        
        let expectation = expectationWithDescription("Satisfied condition expecation")
        
        task
            .onComplete { value in
                XCTAssert(task.conditionErrors.count == 0, "Condition error count should be 1")
                expectation.fulfill()
            }.onError { error in
                XCTAssert(false, "onError block should not be executed")
        }
        
        TaskQueue.main.addTask(task)
        
        waitForExpectationsWithTimeout(1) {
            handlerError in
            print(handlerError)
        }
    }

}
