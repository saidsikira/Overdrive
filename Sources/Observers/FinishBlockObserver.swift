//
//  FinishBlockObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

internal class FinishBlockObserver: TaskObserver {
    var finishExecutionBlock: (Void -> ())
    
    init(finishExecutionBlock: (Void -> ())) {
        self.finishExecutionBlock = finishExecutionBlock
    }
    
    func taskDidStartExecution<T>(task: Task<T>) {
        
    }
    
    func taskDidFinishExecution<T>(task: Task<T>) {
        finishExecutionBlock()
    }
}
