//
//  Dispatch.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

/**
 Provides top-level interface for some `GCD` API calls.
*/
internal class Dispatch {
    
    /**
     Use this method to **synchronously** dispatch block of code to the
     dispatch queue.
     
     Should be used instead of `NSLock` and `NSRecursive` locks.
     
     - Parameter queue: `dispatch_queue_t` used to dispatch block
     - Parameter block: Block of code to be dispatched
    */
    class func sync(queue: dispatch_queue_t, block: () -> Void) {
        dispatch_sync(queue, block)
    }
    
    /**
     Use this method to **synchronously** dispatch block that returns value.
     
     This method is relatively cheaper than `NSLock` and `NSRecursiveLock`
     lock mechanisms and can be used to make object thread safe
     without needing to syncronize with locks.
     
     ### Example:
     ```swift
     var internalState = 0
     public var state: Int {
        return Dispatch.sync {
            return internalState
        }
     }
     ```
     
     - Parameter queue: `dispatch_queue_t` used to dispatch block
     - Parameter block: Block of code to be dispatched
     
     - Returns: `T` object returned from block
    */
    class func sync<T>(queue: dispatch_queue_t, block: () -> T) -> T {
        var result: T?
        
        dispatch_sync(queue) {
            result = block()
        }
        return result!
    }
    
    /**
     Use this method to **asynchronously** dispatch block of code to the
     dispatch queue.
     
     - Parameter queue: `dispatch_queue_t` used to dispatch block
     - Parameter block: Block of code to be dispatched
    */
    class func async(queue: dispatch_queue_t, block: () -> Void) {
        dispatch_async(queue, block)
    }
}
