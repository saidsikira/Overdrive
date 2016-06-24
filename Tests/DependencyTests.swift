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
    func testDependencyFromTask() {
        let testTask = TestTask()
        let dependencyTask = SimpleTask()
        
        testTask.addDependency(dependencyTask)
        
        if testTask.dependency(SimpleTask) == nil {
            XCTAssert(false, "Should return dependency")
        }
    }
}
