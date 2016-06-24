//
//  Array+Overdrive.swift
//  Overdrive
//
//  Created by Said Sikira on 6/24/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

extension Array where Element: TaskObserver {
    
    /**
     Removes task observer from the array.
     
     - Parameter observer: Task observer instance to be removed
     
     - Returns: Boolean indicating whether observer is removed
    */
    mutating func remove(observer observer: TaskObserver) -> Bool {
        let indexOfObserver = indexOf { $0.observerName == observer.observerName }
        guard indexOfObserver != nil else {
            return false
        }
        removeAtIndex(indexOfObserver!)
        return true
    }
}
