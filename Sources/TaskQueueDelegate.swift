//
//  TaskQueueDelegate.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Delegate of `TaskQueue` that can respond to certain `TaskQueue` events
*/
public protocol TaskQueueDelegate: class {
    
    /**
     Notifies reciever that the task was added to the queue.
     
     - Note: This method is called also when task execution is retried
     
     - Parameter task: Task that was added
     - Parameter queue: Queue in which task was added
    */
    func didAdd<T>(task: Task<T>, toQueue queue: TaskQueue)
    
    /**
     Notifies reciever that the task finished with execution
     
     - Parameter task: Task that finished execution
     - Parameter queue: Queue in which task was added
     */
    func didFinish<T>(task: Task<T>, inQueue queue: TaskQueue)
}
