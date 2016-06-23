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
    func testCollectionTypeExtension() {
        let simpleTask = SimpleTask()
        let failableTask = FailableTask()
        let testTask = TestTask()
        
        testTask.addDependency(simpleTask)
        
    }
}
