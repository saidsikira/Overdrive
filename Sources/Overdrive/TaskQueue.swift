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
 queue.addTask(task)
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
 Service**](https://developer.apple.com/library/ios/documentation/Performance/Con
 ceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html) aware task queues by
 passing `NSQualityOfService` object to the initializer.
 
 **Quality Of Service** class allows you to categorize type of work that is
 executed. For example `.UserInteractive` quality of service class is used for
 the work that is performed by the user and that should be executed immediately.
 
 To create `TaskQueue` with specific `QOS` class use designated initializer:
 
 ```swift
 let queue = TaskQueue(qos: .UserInteractive)
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
 queue.maxConcurrentOperationCount = 3
 ```
 
 ### **TaskQueueDelegate**
 
 `TaskQueue` has a custom delegate which can be used to monitor certain events
 in `TaskQueue` lifecycle. See `TaskQueueDelegate` for more information
 
 */
open class TaskQueue: OperationQueue {
    
    /**
     Returns queue associated with application main queue.
     
     **Example**
     
     ```swift
     let task = SomeTask()
     TaskQueue.uiQueue.addTask(task)
     ```
     */
    open static let uiQueue: TaskQueue = {
        let queue = TaskQueue()
        queue.underlyingQueue = OperationQueue.main.underlyingQueue
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
    open static let background: TaskQueue = {
        let queue = TaskQueue()
        queue.name = "BackgroundTaskQueue"
        queue.underlyingQueue = DispatchQueue.global(qos: .background)
        return queue
    }()
    
    /// TaskQueue delegate object
    weak open var delegate: TaskQueueDelegate?
    
    //MARK: Init methods
    
    /// Creates instance of `TaskQueue`
    public override init() {
        super.init()
    }
    
    /**
     Initilizes TaskQueue with specific `NSQualityOfService` class. Defining
     quality of service class will later determine how tasks are executed.
     */
    public init(qos: QualityOfService) {
        super.init()
        super.qualityOfService = qos
    }
    
    /**
     Initializes TaskQueue with specific dispatch queue.
     
     - note: Setting underlying queue for the TaskQueue will override any
     Quality Of Service setting on TaskQueue.
    */
    public init(queue: DispatchQueue) {
        super.init()
        super.underlyingQueue = queue
    }
    
    //MARK: Task management
    
    /**
     Add task to the TaskQueue and starts execution. Method will call
     delegate method responsible for adding task.
     
     - Parameter task: Task<T> to be added
     */
    open func addTask<T>(_ task: Task<T>) {
        let finishObserver = FinishBlockObserver { [weak self] in
            if let queue = self {
                queue.delegate?.didFinish(task: task, inQueue: queue)
            }
        }
        
        task.add(observer: finishObserver)
        
        // Evaluate condition dependencies and add them to the queue
        _ = task
            .conditions
            .flatMap { $0.dependencies(forTask: task) }
            .map { task.addDependency($0); addOperation($0) }
        
        delegate?.didAdd(task: task, toQueue: self)
        
        addOperation(task)
    }
    
    open override func addOperation(_ operation: Operation) {
        super.addOperation(operation)
        
        if operation.responds(to: #selector(Task<Any>.willEnqueue)) {
            operation.perform(#selector(Task<Any>.willEnqueue))
        }
    }
    
    /**
     Adds array of tasks to the TaskQueue and starts execution. Method will
     call delegate method responsible for adding tasks.
     
     - Parameter tasks: Array of `Task<T>`
     */
    open func addTasks<T>(_ tasks: [Task<T>]) {
        _ = tasks.map { addTask($0) }
    }
}
