//
//  TaskBase.swift
//  Overdrive
//
//  Created by Said Sikira on 9/11/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSObject
import class Foundation.Operation
import class Foundation.DispatchQueue

extension Operation {
    
    /// Enqueue methods changes task state to `pending`. Default implementation
    /// defined in `Operation` extension does nothing. Subclasses should override
    /// this method to define how they are enqueued.
    ///
    /// - Parameter suspended: Task queue suspended state
    func enqueue(suspended: Bool) {
    }
}

/// Base class of `Task<T>`, responsible for state management.
open class TaskBase: Operation {
    
    // MARK: Dispatch queue
    
    /// Private queue used in task state machine
    let queue = DispatchQueue(label: "overdrive.task", attributes: [])
    
    // MARK: Task state management
    
    /// Internal task state
    ///
    /// - warning: Setting the state directly using this property will result
    /// in unexpected behaviour. Always use the `state` property to set and retrieve
    /// current state.
    fileprivate var internalState: State = .initialized
    
    /// Main task state object. Any state change triggers internal `Foundation.Operation` 
    /// KVO observers.
    ///
    /// - note: You can change state from any thread.
    ///
    /// - seealso: State
    var state: State {
        get {
            return queue.sync { return internalState }
        }
        
        set(newState) {
            
            // Notify internal `Foundation.Operation` observers that task state will be changed
            willChangeValue(forKey: "state")
            
            queue.sync {
                assert(internalState.canTransition(to: newState, ifCancelled: isCancelled),
                       "Invalid state transformation from \(internalState) to \(newState)")
                internalState = newState
            }
            
            // Notifity internal `Foundation.Operation` observers that task state is changed
            didChangeValue(forKey: "state")
        }
    }
    
    override func enqueue(suspended: Bool) {
        if !suspended { state = .pending }
    }
    
    // MARK: `Foundation.Operation` Key value observation
    
    /// Called by `Foundation.Operation` KVO mechanisms to check if task is ready
    @objc class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    /// Called by `Foundation.Operation` KVO mechanisms to check if task is executing
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    /// Called by `Foundation.Operation` KVO mechanisms to check if task is finished
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    @objc class func keyPathsForValuesAffectingIsCancelled() -> Set<NSObject> {
        return ["state" as NSObject]
    }
}
