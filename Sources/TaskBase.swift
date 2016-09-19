//
//  TaskBase.swift
//  Overdrive
//
//  Created by Said Sikira on 9/11/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.Operation


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
    var internalState: State = .initialized
    
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
            
            // Notify internal `NSOperation` observers that state will be changed
            willChangeValue(forKey: "state")
            
            queue.sync {
                assert(internalState.canTransitionToState(newState),
                       "Invalid state transformation")
                internalState = newState
            }
            
            // Notifity internal `NSOperation` observers that state is changed
            didChangeValue(forKey: "state")
        }
    }
}
