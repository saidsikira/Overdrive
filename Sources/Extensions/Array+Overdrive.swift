//
//  Array+Overdrive.swift
//  Overdrive
//
//  Created by Said Sikira on 6/24/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

extension Array where Element: TaskObserver {
    mutating func remove(observer observer: TaskObserver) -> Bool {
        let indexOfObserver = indexOf { $0.observerName == observer.observerName }
        guard indexOfObserver != nil else {
            return false
        }
        removeAtIndex(indexOfObserver!)
        return true
    }
}