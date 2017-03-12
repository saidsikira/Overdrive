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
    func canTransition(to state: State, ifCancelled cancelled: Bool) -> Bool {
        switch (self, state) {
        case (.initialized, .pending):
            return true
        case (.initialized, .finished):
            return cancelled
        case (.pending, .ready):
            return true
        case (.pending, .finished):
            return cancelled
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
