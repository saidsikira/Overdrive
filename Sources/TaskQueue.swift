//
//  TaskQueue.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation
import class Foundation.NSOperationQueue

public class TaskQueue: NSOperationQueue {
    
    public func addTask<T>(task: Task<T>) {
        addOperation(task)
        task.willEnqueue()
    }
    
    public func addTasks<T>(tasks: [Task<T>]) {
        for task in tasks {
            addOperation(task)
            task.willEnqueue()
        }
    }
}
