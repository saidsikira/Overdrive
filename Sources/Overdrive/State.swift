//
//  State.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Internal task state
*/
enum State: Int, Comparable {
    
    /// Task state is `Initialized`
    case initialized
    
    /// Task is cancelled
    case cancelled
    
    /// Task state is `Pending` and ready to evaluate conditions
    case pending
    
    /// Task is ready to execute
    case ready
    
    /// Task is executing
    case executing
    
    /// Task is finished
    case finished
    
    /**
     Check if current state can be changed to other state. 
     You need to perform this check because task state can only occur 
     in already defined way.
     
     - Parameter state: Target state
     
     - Returns: Boolean value indicating whether state change is possible
    */
    func canTransition(to state: State) -> Bool {
        switch (self, state) {
        case (let anyState, .cancelled) where anyState != .cancelled || anyState != .finished:
            return true
        case (.cancelled, .finished):
            return true
        case (.initialized, .pending):
            return true
        case (.pending, .ready):
            return true
        case (.ready, .executing):
            return true
        case (.ready, .finished):
            return true
        case (.executing, .finished):
            return true
        default:
            return false
        }
    }
}

//MARK: - Comparable implementation

func < (lhs: State, rhs: State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

func > (lhs: State, rhs: State) -> Bool {
    return lhs.rawValue > rhs.rawValue
}
