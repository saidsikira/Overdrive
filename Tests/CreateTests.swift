//
//  CreateTests.swift
//  Overdrive
//
//  Created by Said Sikira on 6/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class CreateTests: XCTestCase {
    
    func testTaskCreate() {
        
        let expecation = expectationWithDescription("test")
        
        let someTask = Task<Int>.create {
            return .Value(1)
        }
        
        someTask
            .onComplete {
                value in
                if value == 1 {
                    expecation.fulfill()
                }
        }
        
        TaskQueue.main.addTask(someTask)
        
        waitForExpectationsWithTimeout(1) { handlerError in
            print(handlerError)
        }
    }
}
