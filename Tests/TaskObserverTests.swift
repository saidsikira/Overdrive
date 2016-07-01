//
//  TaskObserverTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/29/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class TestObserver: TaskObserver {
}

class TaskObserverTests: XCTestCase {
    
    /// Test `removeObserver(_:)` method
    func testRemoveObserverInstance() {
        let task = SimpleTask()
        let observer = TestObserver()
        task.addObserver(observer)
        
        XCTAssert(task.observers.count == 1, "Task observer count should be 1")
        
        let removeStatus = task.removeObserver(observer)
        
        XCTAssert(removeStatus == true, "remove(_:) method is not returning true for removed observer")
        
        XCTAssert(task.observers.count == 0, "Task observer count should be 1")
    }
    
    /// Test `removeObserverOfType(_:)`
    func testRemoveObserverOfType() {
        let task = SimpleTask()
        let observer = TestObserver()
        task.addObserver(observer)
        
        XCTAssert(task.observers.count == 1, "Task observer count should be 1")
        
        let removeStatus = task.removeObserverOfType(TestObserver)
        
        XCTAssert(removeStatus == true, "remove(_:) method is not returning true for removed observer")
        
        XCTAssert(task.observers.count == 0, "Task observer count should be 1")
    }
}
