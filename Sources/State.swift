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
    case Initialized
    
    /// Task state is `Pending` and ready to evaluate conditions
    case Pending
    
    /// Task is ready to execute
    case Ready
    
    /// Task is executing
    case Executing
    
    /// Task is finished
    case Finished
    
    /**
     Check if current state can be changed to other state. 
     You need to perform this check because task state can only occur 
     in already defined way.
     
     - Parameter state: Target state
     
     - Returns: Boolean value indicating whether state change is possible
    */
    func canTransitionToState(state: State) -> Bool {
        switch (self, state) {
        case (.Initialized, .Pending):
            return true
        case (.Pending, .Ready):
            return true
        case (.Ready, .Executing):
            return true
        case (.Ready, .Finished):
            return true
        case (.Executing, .Finished):
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
