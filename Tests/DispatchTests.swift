//
//  DispatchTests.swift
//  Overdrive
//
//  Created by Said Sikira on 8/22/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import XCTest
@testable import Overdrive

class DispatchTests: XCTestCase {
    
    func testDispatchSync() {
        let queue = dispatch_queue_create("io.overdrive.queue", nil)
        
        let value = Dispatch.sync(queue) {
            return 10
        }
        
        XCTAssert(value == 10, "Value returned from dispatch queue is not correct")
    }
    
}
