//
//  TaskQueue.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation
import class Foundation.NSOperationQueue

/**
 Provides `Task<T>` execution and manages dependencies and concurrency.
 
 **Example**
 
 ```swift
 /// Create new instance of task queue
 let queue = TaskQueue()
 queue.addTask(task)
 ```
 
 ### Specific `NSQualityOfService`
 If you want to perform task execution with defined quality of service class, 
 you need to pass it to the initializer.
 
 ```swift
 /// Create background task queue
 let queue = TaskQueue(qos: .Background)
 ```
 
 ### Performing work on main queue
 To perform task execution on the main queue you can use `main` property of the
 `TaskQueue`
 
 ```swift
 TaskQueue.main.addTask(task)
 ```
 
 */
public class TaskQueue: NSOperationQueue {
    
    /**
     Returns queue associated with application main queue.
     
     **Example**
     
     ```swift
     let task = SomeTask()
     TaskQueue.main.addTask(task)
     ```
    */
    public static var main: TaskQueue = {
        let queue = TaskQueue()
        queue.underlyingQueue = dispatch_get_main_queue()
        return queue
    }()
    
    /**
     Returns queue associated with application background queue.
     
     **Example:**
     
     ```swift
     let task = SomeTask()
     TaskQueue.background.addTask(task)
     ```
    */
    public static var background: TaskQueue = {
        let queue = TaskQueue()
        queue.name = "BackgroundTaskQueue"
        queue.underlyingQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        return queue
    }()
    
    /// TaskQueue delegate object
    weak public var delegate: TaskQueueDelegate?
    
    //MARK: Init methods
    
    /// Creates instance of `TaskQueue`
    public override init() {
        super.init()
    }
    
    /**
     Initilizes TaskQueue with specific `NSQualityOfService` class. Defining
     quality of service class will later determine how tasks are executed.
     */
    public init(qos: NSQualityOfService) {
        super.init()
        self.qualityOfService = qos
    }
    
    //MARK: Task management
    
    /**
     Add task to the TaskQueue and starts execution. Method will call
     delegate method responsible for adding task.
     
     - Parameter task: Task<T> to be added
     */
    public func addTask<T>(task: Task<T>) {
        let finishObserver = FinishBlockObserver { [weak self] in
            if let queue = self {
                queue.delegate?.didFinish(task: task, inQueue: queue)
            }
        }
        
        task.addObserver(finishObserver)
        
        if task.shouldRetry {
            let retryObserver = RetryTaskObserver { [weak self] in
                if let queue = self {
                    queue.retry(task: task)
                }
            }
            task.addObserver(retryObserver)
        }
        
        addOperation(task)
        delegate?.didAdd(task: task, toQueue: self)
        
        task.willEnqueue()
    }
    
    /**
     Adds array of tasks to the TaskQueue and starts execution. Method will
     call delegate method responsible for adding tasks.
     
     - Parameter tasks: Array of `Task<T>`
     */
    public func addTasks<T>(tasks: [Task<T>]) {
        _ = tasks.map { addTask($0) }
    }
    
    /**
     Retries task execution. Method will decrease task retry count, set task
     state to `Initialized` and add it to the queue again.
     
     - Parameter task: Task to be retried
    */
    func retry<T>(task task: Task<T>) {
        do {
            try task.decreaseRetryCount()
            task.state = .Initialized
            addOperation(task)
            task.willEnqueue()
            delegate?.didRetry(task: task, inQueue: self)
        } catch {
            
        }
    }
}
