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
        let queue = DispatchQueue(label: "io.overdrive.queue", attributes: [])
        
        let value = queue.sync {
            return 10
        }
        
        XCTAssert(value == 10, "Value returned from dispatch queue is not correct")
    }
    
}
