//
//  FinishBlockObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Task observer that is used to notify `TaskQueue` that the task finished execution.
*/
class FinishBlockObserver: TaskObserver {
    
    /**
     Completion block that will be executed when task finished execution.
     
     Called regardless of the task result.
    */
    var finishExecutionBlock: ((Void) -> ())
    var willFinishExecutionBlock: ((Void) -> ())
    
    var observerName: String = "FinishBlockObserver"
    
    /// Create new `FinishBlockObserver` with completion block
    init(finishExecutionBlock: @escaping ((Void) -> ()), willFinishExecutionBlock: @escaping ((Void) -> ())) {
        self.finishExecutionBlock = finishExecutionBlock
        self.willFinishExecutionBlock = willFinishExecutionBlock
    }
    
    func taskDidStartExecution<T>(_ task: Task<T>) {
    }
    
    func taskDidFinishExecution<T>(_ task: Task<T>) {
        finishExecutionBlock()
    }

    func taskWillFinishExecution<T>(_ task: Task<T>) {
        willFinishExecutionBlock()
    }
}
