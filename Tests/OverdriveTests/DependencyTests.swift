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
        
        let status = task.remove(dependency: type(of: dependency))
        
        XCTAssertEqual(status, true)
        XCTAssertEqual(task.dependencies.count, 0)
    }
    
    func testRemoveUnknownDependencyWithType() {
        let task = Task<Int>()
        let dependency = Task<String>()
        
        task.add(dependency: dependency)
        
        let status = task.remove(dependency: Task<Double>.self)
        
        XCTAssertEqual(status, false)
        XCTAssertEqual(task.dependencies.count, 1)
    }
    
    
}
