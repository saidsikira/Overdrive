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
    var finishExecutionBlock: (Void -> ())
    
    /// Create new `FinishBlockObserver` with completion block
    init(finishExecutionBlock: (Void -> ())) {
        self.finishExecutionBlock = finishExecutionBlock
    }
    
    func taskDidStartExecution<T>(task: Task<T>) {
        
    }
    
    func taskDidFinishExecution<T>(task: Task<T>) {
        finishExecutionBlock()
    }
}
