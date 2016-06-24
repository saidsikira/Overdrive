//
//  RetryTaskObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/23/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Task observer used to notify TaskQueue that the task should retry execution.
 
 `RetryTaskObserver` works by checking if task result contains an error, and if
 it does, `retryBlock` will be executed.
*/
class RetryTaskObserver: TaskObserver {
    
    /// Retry block that will be executed if task should retry execution
    let retryBlock: (Void -> ())
    
    var observerName: String = "RetryTaskObserver"
    
    /// Create new `RetryTaskObserver` with completion block.
    init(retryCompletionBlock: (Void -> ())) {
        retryBlock = retryCompletionBlock
    }
    
    func taskDidFinishExecution<T>(task: Task<T>) {
        // Check if task contains result
        guard let result = task.result else {
            return
        }
        
        // Call retry block if task finished with error
        switch result {
        case .Error(_):
            retryBlock()
        default:
            return
        }
    }
}
