//
//  Create.swift
//  Overdrive
//
//  Created by Said Sikira on 6/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Provides helper synchronous task execution by finishing with result immediately
*/
private class SynchronousTask<T>: Task<T> {
    override func run() {
        if let result = result {
            finish(result)
        } else {
            moveToFinishedState()
        }
    }
}

extension Task {
    
    //MARK: Task creation
    
    /**
     Create inline synchronus task by returning result in the completion block.
     
     **Example:**
     
     ```swift
     let inlineTask = Task.create {
        return .Value(10)
     }
     ```
     
     - Parameter resultBlock: Block in which task is executed. To finish execution,
     you must return from the completion block with `Result<T>`.
     
     - Returns: `Task<T>` instance
    */
    public class func create(@noescape resultBlock: (Void -> Result<T>)) -> Task<T> {
        let builder = SynchronousTask<T>()
        builder.result = resultBlock()
        return builder
    }
}
