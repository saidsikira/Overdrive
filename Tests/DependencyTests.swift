//
//  DependencyTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/23/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class TestTask: Task<Int> {
    override func run() {
        finish(.Value(1))
    }
}

class DependencyTests: XCTestCase {
    
    /// Test `addDependency(_:)` method
    func testDependencyAdd() {
        let testTask = TestTask()
        let dependencyTask = SimpleTask()
        
        testTask.addDependency(dependencyTask)
        
        XCTAssert(testTask.dependencies.count == 1, "Dependencies count should be 1")
        
        TaskQueue(qos: .default).addTask(testTask)
    }
    
    /// Tests `getDependency(_:)` method
    func testGetDependency() {
        let testTask = TestTask()
        let dependencyTask = SimpleTask()
        dependencyTask.name = "DependencyTask"
        
        testTask.addDependency(dependencyTask)
        
        if let dependency = testTask.getDependency(SimpleTask.self) {
            XCTAssert(dependency.name == "DependencyTask", "Incorrect dependency returned")
        } else {
            XCTAssert(false, "Dependency not returned")
        }
    }
}
