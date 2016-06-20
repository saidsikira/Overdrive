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
    
    public static var main: TaskQueue = TaskQueue(qos: .Default)
    
    weak var delegate: TaskQueueDelegate?
    
    //MARK: Init methods
    
    public override init() {
        super.init()
    }
    
    public init(qos: NSQualityOfService) {
        super.init()
        self.qualityOfService = qos
    }
    
    //MARK: Task management
    
    public func addTask<T>(task: Task<T>) {
        addOperation(task)
        delegate?.didAdd(task: task, toQueue: self)
        task.willEnqueue()
    }
    
    public func addTasks<T>(tasks: [Task<T>]) {
        for task in tasks {
            addOperation(task)
            delegate?.didAdd(task: task, toQueue: self)
            task.willEnqueue()
        }
    }
}
