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
        let task = anyTask(withResult: .value(1))
        let observer = SimpleObserver()
        
        task.add(observer: observer)
        
        XCTAssertEqual(task.observers.count, 1)
    }
    
    /// Test `removeObserver(_:)` method
    func testRemoveObserver() {
        let task = anyTask(withResult: .value(1))
        let observer = SimpleObserver()
        task.add(observer: observer)
        
        let removeStatus = task.remove(observer: observer)
        
        XCTAssertEqual(removeStatus, true, "remove(_:) method is not returning true for removed observer")
        
        XCTAssertEqual(task.observers.count, 0)
    }
    
    /// Test `removeObserverOfType(_:)`
    func testRemoveObserverOfType() {
        let task = anyTask(withResult: .value(1))
        let observer = SimpleObserver()
        task.add(observer: observer)
        
        let removeStatus = task.remove(observer: SimpleObserver.self)
        
        XCTAssertEqual(removeStatus, true)
        XCTAssertEqual(task.observers.count, 0)
    }
    
    func testContainsObserver() {
        let task = anyTask(withResult: .value(1))
        let observer = SimpleObserver()
        
        task.add(observer: observer)
        
        XCTAssertTrue(task.contains(observer: SimpleObserver.self))
    }
}
