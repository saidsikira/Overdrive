//
//  TaskQueueDelegate.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

/**
 Delegate of `TaskQueue` that can respond to certain `TaskQueue` events
*/
public protocol TaskQueueDelegate: class {
    
    /**
     Notifies receiver that the task was added to the queue.
     
     - Note: This method is called also when task execution is retried
     
     - Parameter task: Task that was added
     - Parameter queue: Queue in which task was added
     */
    func didAdd<T>(task: Task<T>, to queue: TaskQueue)
    
    /**
     Notifies receiver that the task finished with execution
     
     - Parameter task: Task that finished execution
     - Parameter queue: Queue in which task was added
     */
    func didFinish<T>(task: Task<T>, in queue: TaskQueue)

    /**
     Notifies receiver that the task is about to finish executing

     - Parameter task: Task that will finish execution
     - Parameter queue: Queue in which task was added
     */
    func willFinish<T>(task: Task<T>, in queue: TaskQueue)
}

//MARK: - TaskQueueDelegate default implementations
extension TaskQueueDelegate {
    
    public func didAdd<T>(task: Task<T>, to queue: TaskQueue) {
    }
    
    public func didFinish<T>(task: Task<T>, in queue: TaskQueue) {
    }
    
    public func willFinish<T>(task: Task<T>, in queue: TaskQueue) {
    }
}
