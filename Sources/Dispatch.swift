//
//  Dispatch.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

class Dispatch {
    class func sync(queue: dispatch_queue_t, block: Void -> Void) {
        dispatch_sync(queue, block)
    }
    
    class func sync<T>(queue: dispatch_queue_t, block: Void -> T) -> T {
        var result: T?
        
        dispatch_sync(queue) {
            result = block()
        }
        
        return result!
    }
}