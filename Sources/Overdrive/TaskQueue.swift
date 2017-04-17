//
//  TaskQueue.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.Operation
import class Foundation.OperationQueue
import class Foundation.DispatchQueue
import class Foundation.DispatchGroup
import enum Foundation.QualityOfService

/**
 Provides interface for `Task<T>` execution and concurrency.
 
 ### **Task execution**
 ---
 To schedule task for execution, add it to instance of `TaskQueue` by using
 `addTask(_:)` or `addTasks(_:)` method.
 
 ```swift
 let queue = TaskQueue()
 queue.add(task: someTask)
 ```
 
 After the task is added to the `TaskQueue` complex process of task readiness
 evaluation begins. When the task reaches `ready` state, it is executed until it
 reaches `finished` state by calling `finish(_:)` method inside task.
 
 If task has no conditions or dependencies, it becomes `ready` immediately. If
 task has dependencies or conditions, dependencies are executed first and
 conditions are evaluated after that.
 
 ### **Running tasks on specific queues**
 ---
 
 `TaskQueue` is queue aware, meaning that you can set up the `TaskQueue` object
 with specific dispatch queue so that any task execution performs on that
 defined queue.
 
 There are two predefined `TaskQueue` instances already associated with main
 and background queues.
 
 - `TaskQueue.main` - Associated with main UI thread, suitable for execution
 tasks that application UI is dependent on.
 - `TaskQueue.background` - Associated with background queue. Any task that is
 added to this queue will be executed in the background.
 
 In addition to the queue specification, you can also create [**Quality Of
 Service**](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html) aware task queues by
 passing `NSQualityOfService` object to the initializer.
 
 **Quality Of Service** class allows you to categorize type of work that is
 executed. For example `.UserInteractive` quality of service class is used for
 the work that is performed by the user and that should be executed immediately.
 
 To create `TaskQueue` with specific `QOS` class use designated initializer:
 
 ```swift
 let queue = TaskQueue(qos: .userInteractive)
 ```
 
 ### **Concurrency**
 
 Task queue executes tasks concurrently by default and it's multicore aware
 meaning that it can use full hardware potential to execute work. Tasks do not
 execute one after another, rather they are executed concurrently when they
 reach `ready` state.
 
 To specify maximum number of concurrent task executions use
 `maxConcurrentOperationCount` property.
 
 ```swift
 let queue = TaskQueue()
 queue.maxConcurrentTaskCount = 3
 ```
 
 ### **TaskQueueDelegate**
 
 `TaskQueue` has a custom delegate which can be used to monitor certain events
 in `TaskQueue` lifecycle. See `TaskQueueDelegate` for more information
 
 */
open class TaskQueue {
    
    /// Underlying `Foundation.OperationQueue` instance used for executing
    /// `Foundation.Operation` operations
    internal let operationQueue: OperationQueue = OperationQueue()
    
    /**
     Returns queue associated with application main queue.
     
     **Example**
     
     ```swift
     let task = SomeTask()
     TaskQueue.main.add(task: task)
     ```
     */
    open static let main: TaskQueue = {
        let queue = TaskQueue()
        queue.operationQueue.underlyingQueue = OperationQueue.main.underlyingQueue
        return queue
    }()
    
    /**
     Returns queue associated with application background queue.
     
     **Example:**
     
     ```swift
     let task = SomeTask()
     TaskQueue.background.add(task: task)
     ```
     */
    open static let background: TaskQueue = {
        let queue = TaskQueue()
        queue.operationQueue.underlyingQueue = DispatchQueue.global(qos: .background)
        return queue
    }()
    
    /// TaskQueue delegate object
    weak open var delegate: TaskQueueDelegate?
    
    /// Boolean indicating if queue is actively scheduling tasks execution
    open var isSuspended: Bool {
        get { return operationQueue.isSuspended }
        
        set(suspended) {
            operationQueue.willChangeValue(forKey: "isSuspended")
            operationQueue.isSuspended = suspended
            operationQueue.didChangeValue(forKey: "isSuspended")
            
            for task in tasks {
                task.enqueue(suspended: suspended)
            }
        }
    }
    
    /// Returns all active tasks in the queue
    open var tasks: [Operation] {
        return operationQueue.operations
    }
    
    /// Specifies service level that is used in executing tasks
    /// in the current queue.
    open var qos: QualityOfService {
        get { return operationQueue.qualityOfService }
        
        set(newQos) {
            operationQueue.qualityOfService = newQos
        }
    }
    
    /// Queue name identifier
    open var name: String?
    
    /// The maximum number of tasks that can be executed at the same time
    /// concurrently.
    open var maxConcurrentTaskCount: Int {
        get { return operationQueue.maxConcurrentOperationCount }
        
        set(newCount) {
            operationQueue.maxConcurrentOperationCount = newCount
        }
    }
    
    // MARK: Init methods
    
    /// Creates instance of `TaskQueue`
    public init() {
    }
    
    /**
     Initilizes TaskQueue with specific `NSQualityOfService` class. Defining
     quality of service class will later determine how tasks are executed.
     */
    public init(qos: QualityOfService) {
        operationQueue.qualityOfService = qos
    }
    
    /**
     Initializes TaskQueue with specific dispatch queue.
     
     - note: Setting underlying queue for the TaskQueue will override any
     Quality Of Service setting on TaskQueue.
     */
    public init(queue: DispatchQueue) {
        operationQueue.underlyingQueue = queue
    }
    
    //MARK: Task management
    
    /**
     Add task to the TaskQueue and starts execution. Method will call
     delegate method responsible for adding task.
     
     - Parameter task: Task<T> to be added
     */
    open func add<T>(task: Task<T>) {
        if !task.contains(observer: FinishBlockObserver.self) {
            task.add(observer: FinishBlockObserver(
                finishExecutionBlock: { [weak self, unowned task] in
                    if let queue = self { queue.delegate?.didFinish(task: task, in: queue) }
                },
                willFinishExecutionBlock: { [weak self, unowned task] in
                    if let queue = self {
                        queue.delegate?.willFinish(task: task, in: queue)
                    }
            }))
        }
        
        // Evaluate condition dependencies and add them to the queue
        task
            .conditions
            .flatMap { $0.dependencies(forTask: task) }
            .forEach { add(dependency: $0, forTask: task) }
        
        operationQueue.addOperation(task)
        
        delegate?.didAdd(task: task, to: self)
        
        task.enqueue(suspended: isSuspended)
    }
    
    /// Adds dependency for specific task
    ///
    /// - Parameters:
    ///   - dependency: `Foundation.Operation` subclass
    ///   - task: `Task<T>` to add dependency to
    fileprivate func add<T>(dependency: Operation, forTask task: Task<T>) {
        task.add(dependency: dependency)
        operationQueue.addOperation(dependency)
        
        dependency.enqueue(suspended: isSuspended)
    }
    
    func executeSuspendedTasks() {
    }
}

// MARK: - CustomStringConvertible

extension TaskQueue: CustomStringConvertible {
    public var description: String {
        return name ?? operationQueue.description
    }
}

// MARK: - CustomDebugStringConvertible

extension TaskQueue: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Name: \(String(describing: name)), qos: \(qos), Task count: \(tasks.count)"
    }
}
