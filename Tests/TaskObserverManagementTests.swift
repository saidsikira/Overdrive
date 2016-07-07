//
//  TaskObserverTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/29/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class SimpleObserver: TaskObserver {
}

class TaskObserverManagementTests: XCTestCase {
    
    /// Test `addObserver` method
    func testAddObserver() {
        let task = SimpleTask()
        let observer = SimpleObserver()
        
        task.addObserver(observer)
        
        XCTAssert(task.observers.count == 1, "Task observer count should be 1")
    }
    
    /// Test `removeObserver(_:)` method
    func testRemoveObserver() {
        let task = SimpleTask()
        let observer = SimpleObserver()
        task.addObserver(observer)
        
        let removeStatus = task.removeObserver(observer)
        
        XCTAssert(removeStatus == true, "remove(_:) method is not returning true for removed observer")
        
        XCTAssert(task.observers.count == 0, "Task observer count should be 0")
    }
    
    /// Test `removeObserverOfType(_:)`
    func testRemoveObserverOfType() {
        let task = SimpleTask()
        let observer = SimpleObserver()
        task.addObserver(observer)
        
        let removeStatus = task.removeObserverOfType(SimpleObserver)
        
        XCTAssert(removeStatus == true, "remove(_:) method is not returning true for removed observer")
        
        XCTAssert(task.observers.count == 0, "Task observer count should be 0")
    }
}
