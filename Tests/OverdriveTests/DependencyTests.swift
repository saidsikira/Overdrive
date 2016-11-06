//
//  DependencyTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/23/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
import TestSupport

@testable import Overdrive

class TestTask: Task<Int> {
    override func run() {
        finish(with: .value(1))
    }
}

class DependencyTests: XCTestCase {
    
    /// Test `addDependency(_:)` method
    func testDependencyAdd() {
        let testTask = TestTask()
        let dependencyTask = SimpleTask()
        
        testTask.add(dependency: dependencyTask)
        
        XCTAssertEqual(testTask.dependencies.count, 1)
        
        TaskQueue(qos: .default).add(task: testTask)
    }
    
    /// Tests `getDependency(_:)` method
    func testGetDependency() {
        let testTask = TestTask()
        let dependencyTask = SimpleTask()
        dependencyTask.name = "DependencyTask"
        
        testTask.add(dependency: dependencyTask)
        
        if let dependency = testTask.get(dependencyWithType: SimpleTask.self) {
            XCTAssertEqual(dependency.name, "DependencyTask")
        } else {
            XCTFail("Dependency not returned")
        }
    }
    
    func testDependencySubscript() {
        let testTask = TestTask()
        let dependencyTask = SimpleTask()
        dependencyTask.name = "DependencyTask"
        
        testTask.add(dependency: dependencyTask)
        
        let dependency = testTask[SimpleTask.self]

        XCTAssertNotNil(dependency, "Should retrurn dependency")
        XCTAssertEqual(dependency?.name, "DependencyTask")
    }
}
