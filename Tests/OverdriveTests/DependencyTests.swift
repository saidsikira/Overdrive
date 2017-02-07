//
//  DependencyTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/23/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest

@testable import Overdrive

class DependencyTests: TestCase {
    
    /// Test `addDependency(_:)` method
    func testDependencyAdd() {
        let testTask = Task<Int>()
        let dependencyTask = Task<String>()
        
        testTask.add(dependency: dependencyTask)
        
        XCTAssertEqual(testTask.dependencies.count, 1)
    }
    
    /// Tests `getDependency(_:)` method
    func testGetDependency() {
        let testTask = Task<Int>()
        let dependencyTask = Task<String>()
        dependencyTask.name = "DependencyTask"
        
        testTask.add(dependency: dependencyTask)
        
        let dependencies = testTask.get(dependency: type(of: dependencyTask))
        XCTAssertEqual(dependencies[0].name, "DependencyTask")
    }
    
    func testRemoveValidDependency() {
        let task = Task<Int>()
        let dependency = Task<String>()
        
        task.add(dependency: dependency)
        
        let status = task.remove(dependency: dependency)
        
        XCTAssertEqual(status, true)
        XCTAssertEqual(task.dependencies.count, 0)
    }
    
    func testRemoveDependencyWithType() {
        let task = Task<Int>()
        let dependency = Task<String>()
        
        task.add(dependency: dependency)
        
        task.remove(dependency: type(of: dependency))
        
//        XCTAssertEqual(status, true)
        XCTAssertEqual(task.dependencies.count, 0)
    }
    
    func testRemoveUnknownDependencyWithType() {
        let task = Task<Int>()
        let dependency = Task<String>()
        
        task.add(dependency: dependency)
        
        task.remove(dependency: Task<Double>.self)
        
        XCTAssertEqual(task.dependencies.count, 1)
    }
    
    func testOrderOfExecution() {
        let testExpecation = expectation(description: "Dependency order of execution test expectation")
        
        var results: [Result<Int>] = []

        func add(result: Result<Int>) {
            dispatchQueue.sync {
                results.append(result)
            }
        }
        
        let firstTask = anyTask(withResult: .value(1))
        let secondTask = anyTask(withResult: .value(2))
        let thirdTask = anyTask(withResult: .value(3))
        
        thirdTask.add(dependency: secondTask)
        secondTask.add(dependency: firstTask)
        
        firstTask.onValue { add(result: .value($0)) }
        secondTask.onValue { add(result: .value($0)) }
        
        thirdTask.onValue {
            add(result: .value($0))
            testExpecation.fulfill()
            
            XCTAssertEqual(results[0].value, 1)
            XCTAssertEqual(results[1].value, 2)
            XCTAssertEqual(results[2].value, 3)
        }
        
        let queue = TaskQueue(qos: .utility)
        
        queue.add(task: thirdTask)
        queue.add(task: secondTask)
        queue.add(task: firstTask)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
	
    func testCancellationOfDependentTask() {
        let queue = TaskQueue()
        let delay: TimeInterval = 1.0
        let delayTask = TestCaseDelayedTask(withResult: .value(()), delay: delay)

        let equalExpectation = expectation(description: "value is equal to initial value")
        let initialValue = 0
        var value = initialValue

        let modifyTask = InlineTask({
            value = 1
        })
        modifyTask.add(dependency: delayTask)

        let checkTask = InlineTask({
            XCTAssert(value == initialValue)
            equalExpectation.fulfill()
        })
        checkTask.add(dependency: modifyTask)

        queue.add(task: delayTask)
        queue.add(task: modifyTask)
        queue.add(task: checkTask)
        
        modifyTask.cancel()
        
        waitForExpectations(timeout: delay + 0.5)
    }
}
