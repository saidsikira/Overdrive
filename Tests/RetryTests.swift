//
//  RetryTests.swift
//  Overdrive
//
//  Created by Said Sikira on 8/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class RetryTestTask: Task<Int> {
    private(set) var failCount: Int
    
    init(failCount: Int) {
        self.failCount = failCount
    }
    
    override func run() {
        if failCount == 0 {
            NSLog("new fail count \(failCount)")
            finish(.Value(1))
        } else {
            failCount -= 1
            finish(.Error(TaskError.Fail("Failed with retry count \(failCount)")))
        }
    }
}

class RetryTests: XCTestCase {
    
    func testRetryCount() {
        let retryTestTask = RetryTestTask(failCount: 5)
        
        XCTAssert(retryTestTask.retryCount == 0, "retryCount should be 0")
        
        retryTestTask.retry(3)
        
        XCTAssert(retryTestTask.retryCount == 3, "retryCount should be 0")
    }
    
    func testReduceRetryCount() {
        let retryTestTask = RetryTestTask(failCount: 3)
        retryTestTask.retry(3)
        
        do {
            try retryTestTask.decreaseRetryCount()
            XCTAssert(retryTestTask.retryCount == 2, "Retry count after decreasing incorrect")
        } catch {
            XCTFail("Decrease count failed with error \(error)")
        }
    }
    
    func testRetry() {
        let retryExpectation = expectationWithDescription("Task should be retried")
        
        let retryTestTask = RetryTestTask(failCount: 5)
        
        // Set retry count
        retryTestTask.retry(5)
        
        // Set onValue and onError
        retryTestTask
            .onValue { value in
                XCTAssert(retryTestTask.retryCount == 0, "Retry count is not correct")
                retryExpectation.fulfill()
                
            }.onError { error in
                XCTFail("Task should not fail with error \(error)")
        }
        
        TaskQueue.main.addTask(retryTestTask)
        
        waitForExpectationsWithTimeout(0.2) { handlerError in
            print(handlerError)
        }
    }
}
