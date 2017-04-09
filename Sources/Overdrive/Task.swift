//
//  Task.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

/**
 `Task<T>` is an abstract class that provides interface for encapsuling any
 asynchronous or synchronous operation. Subclassing `Task<T>`
 is simple operation. You are only required to override `run()` method that
 defines task execution point and call `finish(_:)` method to finish execution.
 In order to execute any task you need to add it to the `TaskQueue` which
 manages task execution, concurrency and threading mechanisms.
 
 `Task` also provides method chaining and completion blocks that are executed
 depending on the task result. It also features retry mechanisms for tasks
 which finished with errors.
 
 There are several key aspects of the `Task<T>` that you need to understand:
 
 1. **State machine** - `Task<T>` works with internal task state machine. State
 of the task at any point can be:
 
	* initialized - Task instance is created
	* pending - Task is added to the `TaskQueue` and started process of
	evaluating readiness
	* ready - Task is ready to execute.
	* executing - Task is executing
	* finished - Task finished with execution
 
 2. **Task execution point** - Task execution starts in `run()` method when state
 reaches `ready` state. You should always override this method in your subclass.
 
 3. **Finishing execution** - Task execution finishes when `finish(_:)` method is
 called. You always finish execution with `Result<T>` object. `Result<T>` is an
 enum with two cases:
 
	* `value(T)`
	* `error(Error)`
 
 After `finish(with:)` method is called, you can access result through `result`
 property.
 
 - note: You can access `result` object from any thread.
 
 **Example subclass**
 
 ```swift
 class SomeTask: Task<Int> {
     override func run() {
         asyncOperation { data, error in
             if error != nil {
                finish(with: .error(error!))
             } else {
                finish(with: .value(data as! Int))
             }
         }
     }
 }
 
 let queue = TaskQueue()
 let task = SomeTask()
 queue.add(task: task)
 ```
 
 ### **Completion blocks**
 ---
 You can use one of the defined completion blocks that are executed when task
 finished with execution.
 
 1. `onValue` - executed when task finishes with `.value(T)`
 2. `onError` - executed when task finishes with `.error(Error)`
 
 ```swift
 let task = SomeTask()
 
 task
    .onValue { value in
        print(value) // Int
    }.onError { error in
        print(error)
 }
 ```
 
 - note: Many of the `Task` methods can be chained to enable simple setup
 
 - warning: Calling `onValue` and `onError` methods after the task is added
 to the `TaskQueue` may result in error, since the task may have already finished
 with execution. To avoid this behaviour, always call these methods before task
 is added to the `TaskQueue`.
 
 ### **Dependencies**
 ---
 
 Complex tasks should be always divided into several smaller tasks. To make sure
 that tasks are executed in the correct order you can use dependencies. To add
 dependency use `addDependency(_:)` method.
 
 ```swift
 let task = SomeTask()
 let otherTask = OtherTask()
 
 task.add(dependency: otherTask)
 ```
 
 When task with dependencies is added to the `TaskQueue`, dependencies will be
 executed first.
 
 - note: You can access all task dependencies with `dependencies` property.
 
 ### **Conditions**
 ---
 
 In some cases, tasks need conditions to be satisfed in order to be executed.
 
 One example would be location retrieval. In order to get location from the
 device you need to make sure that user granted permissions for location
 services. Granting permissions can be exposed as task condition. You can create conditions using `TaskCondition` protocol and add them to the task by using
 `add(condition:)` method.
 
 ### **Observers**
 ---
 
 In addition to the `onValue` and `onError` completion methods, you can use
 `TaskObserver` protocol to be notified when task starts and finishes with
 execution.
 
 Classic example would be creating observer that manages `UIActivityIndicator`
 based on the task execution state.
 
 ### **Retry**
 ---
 
 If the task finishes execution with error, its execution can be retried. To
 specify maximum number of retry operations use `retry(_:)` method.
 
 ```swift
 let task = SomeTask()
 
 task
    .retry(3)
    .onValue { value in
        print(value)
    }.onError { error in
        print(error)
    }
 ```
 
 - note: `retry(_:)` method can be chained with other task methods
*/
open class Task<T>: TaskBase {
    
    public typealias ResultType = T
    
    //MARK: Internal properties
    
    /// Internal result object
    ///
    /// - warning: Should never be set directly, only via `result` property
    fileprivate var internalResult: Result<ResultType>?
    
    /// Internal completion block
    ///
    /// - warning: Accessing this property directly will result in unexpected behavior.
    /// Use `onValueBlock` instead.
    fileprivate var internalOnValueBlock: ((ResultType) throws -> Void)?
    
    /// Internal error completion block
    ///
    /// - warning: Accessing this property directly will result in unexpected behavior.
    /// Use `onErrorBlock` instead.
    ///
    fileprivate var internalOnErrorBlock: ((Error) -> Void)?
    
    /// Internal task observers
    fileprivate var internalObservers: [TaskObserver] = []
    
    /// Internal task conditions
    fileprivate var internalConditions: [TaskCondition] = []
    
    /// Internal number of retry counts
    fileprivate var internalRetryCount: Int = 0
    
    /// Internal condition errors
    fileprivate var internalConditionErrors = [Error]()
    
    //MARK: Class properties
    
    ///
    /// Task result. Result can contain either value or error.
    ///
    /// `value(T)`: value of type defined by the Task
    ///
    /// `error(Error)`: error that may have occured
    ///
    /// This object will not be populated with result until task
    /// achieves `finished` state. You can access the result value directly,
    /// or setup completion blocks that will execute when task finishes.
    ///
    /// - seealso: `onValue(_: )`, `onError(_: )`
    internal(set) open var result: Result<T>? {
        get { return queue.sync {
                return internalResult }
        }
        
        set(newResult) {
            queue.sync {
                internalResult = newResult
            }
        }
    }
    
    /// Returns current retry count
    var retryCount: Int {
        get { return queue.sync {
                return internalRetryCount }
        }
        
        set(newCount) {
            queue.sync {
                internalRetryCount = newCount
            }
        }
    }
    
    // MARK: Completion methods
    
    ///
    /// Completion block that is executed when the task reaches `finished` state and
    /// `.value(T)` is passed to the `finish(with:)` method. Completion block takes one
    /// argument `T`, which is `.value` component from the task result.
    ///
    /// See `Result<T>`.
    ///
    /// Block should be set by using `onValue:` method on `Self`.
    ///
    /// - Warning: Setting this property directly may result in unexpected behaviour.
    /// Always use `onValue(_:)` method on `Self` to set the block.
    var onValueBlock: ((T) throws -> Void)? {
        get { return queue.sync {
                return internalOnValueBlock
            }
        }
        
        set(newBlock) { queue.sync {
                internalOnValueBlock = newBlock
            }
        }
    }
    
    /// Completion block that is executed when the task reaches `Finished` state and
    /// error is passed to the `finish:` method. Completion block has one argument,
    /// `ErrorType` and no return type. `ErrorType`.
    ///
    /// Block should be set by using `onError:` method on `Self`.
    ///
    /// - Warning: Setting this property directly may result in unexpected behaviour,
    /// always use `onError:` method on `Self` to set the block.
    var onErrorBlock: ((Error) -> Void)? {
        get { return queue.sync {
                return internalOnErrorBlock
            }
        }
        
        set(newBlock) {
            if newBlock != nil {
                queue.sync {
                    internalOnErrorBlock = newBlock
                }
            }
        }
    }
    
    /// Use this method to set completion block that will be executed when task
    /// finishes execution with `.value(T)` result.
    ///
    /// - Note:
    /// If the task finishes with `.error` result, `onError(_:)` method will be called.
    ///
    /// - Warning: This method should only be called before the task state becomes `.Pending`.
    /// Calling this method after `.pending` state may result in unexpected behaviour.
    ///
    /// - Parameter completion: Completion block that should be executed. Takes `T` parameter
    /// which is extracted from the `.value(T)` result. If error is thrown in `completion`, it
    /// will be passed down to the `onError(:_)` method.
    ///
    /// - Returns: `Self`. This method will always return itself, so that it can be used
    /// in chain with other task methods.
    @discardableResult
    public final func onValue(_ completion: @escaping ((ResultType) throws -> Void)) -> Self {
        assert(state < .executing, "On complete called after task is executed")
        onValueBlock = completion
        return self
    }
    
    /// Use this method to set completion block that will be executed when task
    /// finishes with error.
    ///
    /// - Note: Completion block set will only be executed if the
    /// task finishes with `.error` result.
    ///
    /// If the task finishes with `.value` result, onValue completion will be called.
    ///
    /// - Warning: This method should only be called before the task state becomes `.Pending`.
    /// Calling this method after `.pending` state may result in unexpected behaviour.
    ///
    /// - Parameter completion: Completion block that should be executed. Takes only
    /// one `Error` parameter and no return type.
    ///
    /// - Returns: `Self`. This method will always return itself, so that it can be used
    /// in chain with other task methods.
    /// */
    @discardableResult
    public final func onError(_ completion: @escaping ((Error) -> ())) -> Self {
        assert(state < .executing, "On complete called after task is executed")
        onErrorBlock = completion
        return self
    }
    
    /// Completion block that will be executed when the task finishes execution.
    ///
    /// - warning: **DEPRECATED**. Use `onValue(_:)` method to set completion
    /// block.
    @available(*, deprecated, message : "use onValue completion instead")
    open override var completionBlock: (() -> Void)? {
        get { return super.completionBlock }
        set(newBlock) { super.completionBlock = newBlock }
    }
    
    // MARK: Retry mechanims
    
    
    /// Set retry count. If the task finishes with error, it will be executed
    /// again until retry count becomes zero.
    ///
    /// - parameter times: Number of times task should be retried if it finishes with error
    ///
    /// - returns: `self`
    @discardableResult
    public final func retry(_ times: Int = 1) -> Self {
        retryCount = times
        return self
    }
    
    /// Attempts to retry execution
    fileprivate func attemptRetry() {
        if let _ = try? decreaseRetryCount() {
            run()
        } else {
            moveToFinishedState()
        }
    }
    
    /// Returns true if task should be retried
    var shouldRetry: Bool {
        return internalRetryCount > 0
    }
    
    /// Decreases retry count by 1 if task requested rety. 
    /// If retry count is 0, method will throw.
    ///
    /// - throws: RetryError.countIsZero
    func decreaseRetryCount() throws {
        if retryCount > 0 {
            retryCount = retryCount - 1
        } else {
            throw RetryCountError.countIsZero
        }
    }
    
    // MARK: Task conditions
    
    /// All task conditions
    fileprivate(set) open var conditions: [TaskCondition] {
        get { return queue.sync {
                return internalConditions }
        }
        
        set(newConditions) {
            queue.sync {
                internalConditions = newConditions
            }
        }
    }
    
    /// Returns any errors that occured during condition evaluation. If this
    /// array contains errors after evalutation, task **will finish with execution**
    /// and execute `onError:` method.
    var conditionErrors: [Error] {
        get { return queue.sync {
                return internalConditionErrors }
        }
        
        set(newErrors) {
            queue.sync {
                internalConditionErrors = newErrors
            }
        }
    }
    
    /// Adds condition to the task.
    ///
    /// - parameter condition: `TaskCondition` to be added
    ///
    /// - warning: Task conditions should be added before task starts with execution. Otherwise,
    /// assertion will occur.
    open func add(condition: TaskCondition) {
        assert(state < .executing, "Tried to add condition after task started with execution")
        conditions.append(condition)
    }
    
    /// Removes condition from the task.
    ///
    /// - parameter condition: condition to be removed
    ///
    /// - returns: Boolean indicating whether condition was removed
    open func remove(condition: TaskCondition) -> Bool {
        assert(state < .executing, "Tried to remove condition after task started with execution")
        let index = conditions.index(where: { $0.conditionName == condition.conditionName })
        
        if let index = index {
            conditions.remove(at: index)
            return true
        }
        
        return false
    }
    
    /// Removes all conditions of given type.
    ///
    /// - parameter type: Type conforming to the `TaskCondition` protocol
    ///
    /// - returns: Boolean indicating whether condition was removed
    open func remove<T: TaskCondition>(condition type: T.Type) -> Bool {
        assert(state < .executing, "Tried to remove condition after task started with execution")
        
        let indexes = conditions
            .enumerated()
            .flatMap { offset, condition -> Int? in
                if type(of: condition) is T.Type { return offset }
                return nil
            }
        
        if indexes.count > 0 {
            indexes.forEach { conditions.remove(at: $0) }
            return true
        }
        
        return false
    }
    
    // MARK: Task observers
    
    /// Array of all task observers (read-only).
    ///
    /// Default implementation contains `FinishBlockObserver` which is used to notify
    /// TaskQueue that the task finished with execution
    internal(set) open var observers: [TaskObserver] {
        get { return queue.sync {
                return internalObservers }
        }
        
        set {
            queue.sync {
                internalObservers = newValue
            }
        }
    }
    
    /// Adds observer to the task.
    ///
    /// - parameter observer: observer to be added
    public final func add(observer: TaskObserver) {
        assert(state < .executing, "Observer added after task started with execution")
        observers.append(observer)
    }
    
    /// Checks if task constains observer of specific `TaskObserver` type
    ///
    /// - Parameter observer: `TaskObserver` type
    /// - Returns: Boolean value indicating if task contains observer
    public func contains<T: TaskObserver>(observer: T.Type) -> Bool {
        let filteredObservers = observers.filter { type(of: $0) == observer }
        if filteredObservers.count > 0 { return true }
        return false
    }
    
    /// Removes task observer from the task observers.
    ///
    /// - parameter observer: Task observer instance to be removed
    ///
    /// - returns: Boolean indicating whether observer is removed
    ///
    /// - warning: Observer removal should be done before task is added to the `TaskQueue`
    open func remove(observer: TaskObserver) -> Bool {
        assert(state < .executing, "Observer removed after task is added to the task queue")
        
        let indexOfObserver = observers.index { $0.observerName == observer.observerName }
        guard indexOfObserver != nil else {
            return false
        }
        observers.remove(at: indexOfObserver!)
        return true
    }
    
    /// Remove all task observers of the defined TaskObserver type. This method will enumerate
    /// through all task observers, check their type and if the type matches the passed type,
    /// observer will be removed.
    ///
    /// - Parameter type: TaskObserver type
    ///
    /// - Returns: Boolean indicating whether observer is removed
    ///
    /// - Warning: Observer removal should be done before task is added to the `TaskQueue`
    ///
    /// **Example**
    ///
    /// ```swift
    /// let myObserver = CustomObserver()
    /// task.add(observer: myObserver)
    ///
    /// task.remove(observer: CustomObserver.self)
    /// ```
    open func remove<T: TaskObserver>(observer type: T.Type) -> Bool {
        assert(state < .executing, "Observer removed after task is added to the task queue")

        let indexes = observers
            .enumerated()
            .flatMap { offset, observer -> Int? in
                if type(of: observer) is T.Type { return offset }
                return nil
            }
        
        if indexes.count > 0 {
            indexes.forEach { observers.remove(at: $0) }
            return true
        }

        return false
    }
    
    // MARK: Finishing Task execution
    
    @available(*, unavailable, renamed: "finish(with:)")
    public final func finish(_ result: Result<ResultType>) {
        self.finish(with: result)
    }
    
    /// Finish execution of the task with result. Calling this method will change
    /// task state to `Finished` and call neccesary completion blocks. If task finished
    /// with `value(T)`, `onValueBlock` will be executed. If task finished with
    /// `error(Error)` result, `onErrorBlock` will be executed.
    ///
    /// - parameter result: Task result (`.value(T)` or `.error(Error)`)
    ///
    /// - note: Safe to call from any thread.
    ///
    /// - seealso: `Result<T>`
    public func finish(with result: Result<ResultType>) {
        if case .error(_) = result, shouldRetry {
            attemptRetry()
            return
        }

        self.result = result

        moveToFinishedState()

        switch result {
        case .value(let value):
            do { try onValueBlock?(value) } catch { onErrorBlock?(error) }
        case .error(let error):
            onErrorBlock?(error)
        }
    }

    /// Defines if task should handle state automatically. Defaults to true.
    public final override var isAsynchronous: Bool {
        return true
    }
    
    /// Boolean value indicating Task readiness value
    open override var isReady: Bool {
        switch state {
        case .initialized:
            return isCancelled
        case .pending:
            if isCancelled == true { return true }
            
            if super.isReady { evaluateConditions() }
            
            return false
        case .ready:
            return super.isReady || isCancelled
        default:
            return false
        }
    }
    
    /// Boolean value indicating Task execution status.
    open override var isExecuting: Bool {
        return state == .executing
    }
    
    /// Boolean value indicating if task finished with execution.
    open override var isFinished: Bool {
        return state == .finished
    }
    
    /// Evaluates all task conditions
    final func evaluateConditions() {
        assert(state == .pending && !isCancelled, "evaluateConditions() was called out-of-order")
        
        if conditions.count > 0 {
            TaskConditionEvaluator.evaluate(conditions, forTask: self) { errors in
                self.conditionErrors = errors
                self.state = .ready
            }
        } else {
            self.state = .ready
        }
    }
    
    /// Changes task state to `finished`
    internal final func moveToFinishedState() {
        for observer in observers {
            observer.taskWillFinishExecution(self)
        }
        
        state = .finished
        
        for observer in observers {
            observer.taskDidFinishExecution(self)
        }
    }
    
    //MARK: Task execution
    
    /// Starts task execution process when task reaches `ready` state.
    public override final func start() {
        if isCancelled {
            moveToFinishedState()
        } else if conditionErrors.count > 0 {
            finish(with: .error(TaskConditionError.combined(errors: conditionErrors)))
        } else {
            main()
        }
    }
    
    /// Starts task execution by being called from the `start()` method. If the task is
    /// cancelled it will move to finished state.
    public override final func main() {
        assert(state == .ready, "Task must be performed on the TaskQueue")
        state = .executing
        
        for observer in observers {
            observer.taskDidStartExecution(self)
        }
        
        if !isCancelled {
            run()
        } else {
            moveToFinishedState()
        }
    }
    
    /// You must override this method in order to provide execution point for the
    /// task. In order to notify task that the task execution finished, call `finish(_:)`
    /// method on self.
    open func run() {
        assertionFailure("run() method should be overrided in \(type(of: self))")
    }
    
    // MARK: Init methods
    
    /// Create new instance of `Task<T>`
    ///
    /// - Parameters:
    ///   - dependencies: Dependencies
    ///   - observers: Observers
    ///   - conditions: Conditions
    public convenience init(dependencies: [Operation] = [],
                            observers: [TaskObserver] = [],
                            conditions: [TaskCondition] = []) {
        self.init()
        
        dependencies.forEach { add(dependency: $0) }
        observers.forEach { add(observer: $0) }
        conditions.forEach { add(condition: $0) }
    }
    
    // MARK: Dependency management
    
    @available(*, unavailable, renamed: "add(dependency:)")
    open override func addDependency(_ operation: Operation) {
        super.addDependency(operation)
    }
    
    @available(*, unavailable, renamed: "remove(dependency:)")
    open override func removeDependency(_ op: Operation) {
        super.removeDependency(op)
    }
    
    /// Makes the task dependant on completion of specific task.
    /// Dependencies can be excuted on arbitary task queues.
    ///
    /// - parameter dependency: Any `Task<T>` instance
    open func add<U>(dependency: Task<U>) {
        assert(state < .executing)

        super.addDependency(dependency)
    }
    
    /// Makes the task dependant on completion of specific task.
    /// Dependencies can be excuted on arbitary task queues.
    ///
    /// - parameter operation: Any `Operation` subclass
    internal func add(dependency: Operation) {
        assert(state < .executing)
        
        super.addDependency(dependency)
    }
    
    /// Returns dependency instances from the task dependencies.
    ///
    /// - parameter type: Dependency task type
    ///
    /// - returns: Array of `Task<T>` dependency instances
    ///
    /// ### Example
    /// ```swift
    /// let dependencyTask = SomeTask()
    /// if let dependency = task.get(dependency: SomeTask.self) {
    ///    print(dependency) // dependencyTask instance
    /// }
    /// ```
    open func get<T>(dependency type: Task<T>.Type) -> [Task<T>] {
        return dependencies
            .flatMap { $0 as? Task<T> }
        
    }
    
    /// Removes dependency from `self`
    ///
    /// - Parameter dependency: Dependency to remove
    /// - Returns: Boolean indicating whether dependency is removed
    open func remove(dependency: Operation) -> Bool {
        assert(state < .executing,
               "Removed dependency after task started with execution")
        
        let dependencyExists = dependencies
            .filter { $0.hashValue == dependency.hashValue }
            .first
        
        super.removeDependency(dependency)
        
        if let _ = dependencyExists {
            return true
        }
        
        return false
    }
    
    /// Removes dependency with specified type
    ///
    /// - Parameter type: Dependency type
    /// - Returns: Boolean indicating if dependencies of `type` are removed
    open func remove<U>(dependency: Task<U>.Type) {
        assert(state < .executing)
        
        dependencies
            .filter { type(of: $0) == dependency }
            .flatMap { $0 }
            .forEach { super.removeDependency($0) }
    }
}

/// Defines errors that can be thrown in task retry process
enum RetryCountError: Error {
    case countIsZero
}
