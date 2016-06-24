//
//  TaskObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Protocol that types implement in order to be notified of significant events
 in task lifecycle.
*/
public protocol TaskObserver {
    
    /**
     Notifies reciever that task began execution
     
     - Parameter task: Task that started execution
    */
    func taskDidStartExecution<T>(task: Task<T>)
    
    /**
     Notifies reciever that task finished execution
     
     - Parameter task: Task that finished execution
    */
    func taskDidFinishExecution<T>(task: Task<T>)
}

extension TaskObserver {
    
    /// Observer name, returns conforming type name (read-only)
    public var observerName: String {
        return String(self.dynamicType)
    }
    
    public func taskDidStartExecution<T>(task: Task<T>) {
    }
    
    public func taskDidFinishExecution<T>(task: Task<T>) {
    }
}
