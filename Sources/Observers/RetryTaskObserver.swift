//
//  RetryTaskObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/23/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

class RetryTaskObserver: TaskObserver {
    
    let retryBlock: (Void -> ())
    
    init(retryCompletionBlock: (Void -> ())) {
        retryBlock = retryCompletionBlock
    }
    
    func taskDidStartExecution<T>(task: Task<T>) {
        
    }
    
    func taskDidFinishExecution<T>(task: Task<T>) {
        guard let result = task.result else {
            return
        }
        
        switch result {
        case .Error(_):
            retryBlock()
        default:
            return
        }
    }
}
