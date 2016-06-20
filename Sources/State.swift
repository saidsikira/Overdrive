//
//  State.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

enum State: Int, Comparable {
    case Initialized
    case Pending
    case Ready
    case Executing
    case Finished
    
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


func < (lhs: State, rhs: State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}