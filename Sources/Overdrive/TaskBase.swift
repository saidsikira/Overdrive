//
//  TaskBase.swift
//  Overdrive
//
//  Created by Said Sikira on 9/11/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.Operation
import class Foundation.DispatchQueue

// MARK: - TaskBase

/// Base class of `Task<T>`. Responsible for state management.
open class TaskBase: Operation {
    
    // MARK: Dispatch queue
    
    /// Private queue used in task state machine
    let queue = DispatchQueue(label: "overdrive.task", attributes: [])
    
    // MARK: Task state management
    
    /// Internal task state
    ///
    /// - warning: Setting the state directly using this property will result
    /// in unexpected behaviour. Use the `state` property to set and retrieve
    /// current state.
    fileprivate var internalState: State = .initialized
    
    /// Main task state object. Any state change triggers internal `Foundation.Operation` observers.
    ///
    /// State can be one of the following:
    ///
    /// * `Initialized`
    /// * `Pending`
    /// * `Ready`
    /// * `Executing`
    /// * `Finished`
    ///
    /// - note: You can change state from any thread.
    var state: State {
        get {
            return queue.sync { return internalState }
        }
        
        set(newState) {
            
            // Notify internal `Foundation.Operation` observers that task state will be changed
            willChangeValue(forKey: "state")
            
            queue.sync {
                assert(internalState.canTransitionToState(newState),
                       "Invalid state transformation")
                internalState = newState
            }
            
            // Notifity internal `Foundation.Operation` observers that task state is changed
            didChangeValue(forKey: "state")
        }
    }
    
    /// This method changes task state to `pending`.
    ///
    /// - note: This method should be called as a final step in adding task to the
    /// `TaskQueue`.
    @objc fileprivate func willEnqueue() {
        state = .pending
    }
}

extension Operation {
    
    /// Changes operation state to `pending` if it responds to
    /// `willEnqueue` selector.
    internal func enqueue() {
        let enqueueSelector = #selector(Task<Any>.willEnqueue)
        
        if self.responds(to: enqueueSelector) {
            self.perform(enqueueSelector)
        }
    }
}

