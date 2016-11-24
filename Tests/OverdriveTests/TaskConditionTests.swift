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
    
    let queue = TaskQueue(qos: .default)
    
    class FailedTestCondition: TaskCondition {
        func evaluate<T>(forTask task: Task<T>, evaluationBlock: ((TaskConditionResult) -> Void)) {
            evaluationBlock(.failed(TaskError.fail("Condition not satisfied")))
        }
    }
    
    class SatisfiedTestCondition: TaskCondition {
        func evaluate<T>(forTask task: Task<T>, evaluationBlock: ((TaskConditionResult) -> Void)) {
            evaluationBlock(.satisfied)
        }
    }
    
    /// Tests failed condition
    func testFailedCondition() {
        let task = anyTask(withResult: .value(1))
        let condition = FailedTestCondition()
        task.add(condition: condition)
        
        XCTAssertEqual(task.conditions.count, 1)
        XCTAssertEqual(task.conditionErrors.count, 0)
        
        let expectation = self.expectation(description: "Task failed condition expecation")
        
        task
            .onValue { value in
                XCTFail("onValue: block should not be executed")
            }.onError { error in
                XCTAssertEqual(task.conditionErrors.count, 1, "Condition error count should be 1")
                expectation.fulfill()
        }
        
        TaskQueue(qos: .default).add(task: task)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    ///Tests satisfied condition
    func testSatisfiedCondition() {
        let task = anyTask(withResult: .value(1))
        let condition = SatisfiedTestCondition()
        task.add(condition: condition)
        
        XCTAssertEqual(task.conditions.count, 1)
        XCTAssertEqual(task.conditionErrors.count, 0)
        
        let expectation = self.expectation(description: "Satisfied condition expecation")
        
        task
            .onValue { value in
                XCTAssertEqual(task.conditionErrors.count, 0)
                expectation.fulfill()
            }.onError { error in
                XCTFail("onError: block should not be executed")
        }
        
        TaskQueue(qos: .default).add(task: task)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testConditionName() {
        let condition = SatisfiedTestCondition()
        
        XCTAssertEqual(condition.conditionName, "SatisfiedTestCondition")
    }
    
    func testRemoveCondition() {
        let task = Task<Int>()
        let condition = SatisfiedTestCondition()
        
        task.add(condition: condition)
        
        XCTAssertEqual(task.conditions.count, 1)
        
        let status = task.remove(condition: condition)
        
        XCTAssertEqual(status, true)
        XCTAssertEqual(task.conditions.count, 0)
    }
    
    func testRemoveConditionWithType() {
        let task = Task<Int>()
        let condition = SatisfiedTestCondition()
        
        task.add(condition: condition)
        
        let status = task.remove(condition: SatisfiedTestCondition.self)
        
        XCTAssertEqual(status, true)
        XCTAssertEqual(task.conditions.count, 0)
    }

}
