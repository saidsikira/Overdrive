//
//  Tests.swift
//  Tests
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest

@testable import Overdrive

class TaskTests: XCTestCase {
    
    let queue = TaskQueue(qos: .default)
    
    func testIntializedState() {
        let task = anyTask(withResult: .value(1))
        XCTAssertEqual(task.state, .initialized, "Task state should be: Initialized")
    }
    
    func testFinishedState() {
        let task = anyTask(withResult: .value(1))
        let expectation = self.expectation(description: "Task finished state expecation")
        
        task.onValue { value in
            XCTAssertEqual(task.state, .finished, "Task state should be: Finished")
            expectation.fulfill()
        }
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testOnValueCompletionBlockValue() {
        let task = anyTask(withResult: .value(1))
        
        task
            .onValue { _ in }
            .onError { _ in }
        
        XCTAssertNotNil(task.onValueBlock, "onValue block should be set")
    }
    
    func testOnErrorCompletionBlockValue() {
        let task = anyTask(withResult: .value(1))
        
        task
            .onValue { _ in }
            .onError { _ in }
        
        
        XCTAssertNotNil(task.onErrorBlock, "onError block should be set")
    }
    
    func testOnValueBlockExecution() {
        let task = anyTask(withResult: .value(1))
        let expectation = self.expectation(description: "Task result value expecation")
        
        task.onValue { value in
            XCTAssertEqual(value, 1, "Task result value should be 1")
            expectation.fulfill()
        }
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testOnErrorBlockExecution() {
        let task = anyTask(withResult: Result<Int>(TaskError.fail("Failed")))
        let expectation = self.expectation(description: "Task result error expecation")
        
        task
            .onError { error in
                expectation.fulfill()
            }.onValue { _ in
                XCTFail("onValue: block should not be executed")
        }
        
        queue.add(task: task)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testOnValueThrow() {
        let task = anyTask(withResult: .value(10))
        let expectation = self.expectation(description: "Task finished with error expectation")
        
        task
            .onValue { value in
                throw TaskError.fail("onValueError")
            }.onError { error in
                XCTAssertNotNil(error as? TaskError)
                expectation.fulfill()
        }
        
        TaskQueue.main.add(task: task)
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testTaskEqueue() {
        let task = Task<Int>()
        
        (task as Operation).enqueue(suspended: false)
        sleep(1)

        /// The moment you call `enqueue()` method, `Foundation.Operation`
        /// KVO observers will check if task is ready for execution. Since
        /// `isReady` property inside `SimpleTask` is not overriden, `state`
        /// will change to `.ready` automatically.
        
        XCTAssertEqual(task.state, .ready)
    }
    
    func testIsCancelled() {
        let task = anyTask(withResult: .value(0))
        task.cancel()
        
        /// operations / tasks MUST report isCancelled = true if cancelled
        XCTAssertTrue(task.isCancelled)
    }
    
    func testStateIfCancelled() {
        let queue = TaskQueue()
        let task = anyTask(withResult: .value(0))
        task.cancel()
        queue.add(task: task)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            
            /// Tasks cancelled while not beeing enqueued yet need to be able
            /// to transition from `initialized` to `finished` state
        
            /// According to `Foundation.Operation` API Reference
            /// operations / tasks MUST finally
            /// report isFinished = true if cancelled
            XCTAssertEqual(task.state, .finished)
            
            /// Tasks MUST NOT call run() if cancelled before being enqueued
            XCTAssert(task.result == nil)
        })
    }
    
    func testCancelSuspendedTask() {
        let task = anyTask(withResult: .value(0))
        queue.isSuspended = true
        queue.add(task: task)
        task.cancel()
        queue.isSuspended = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            
            /// Tasks MUST NOT transition to `pending` state 
            /// if being cancelled before
            XCTAssertEqual(task.state, .finished)
            
            /// Tasks MUST NOT call run() if the queue's 
            /// `isSuspended` state is set to false 
            /// after task has been cancelled
            XCTAssert(task.result == nil)
        })
    }
    
    func testCancellationOfDependentTask() {
        let queue = TaskQueue()
        let delay: TimeInterval = 1.0
        let delayTask = TestCaseTask(withResult: .value(()), delay: delay)
        
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
