//
//  Task.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation

/// Typealias for `NSOperation`
public typealias TaskBase = Operation

/**
 `Task<T>` is an abstract class that provides interface encapsuling any
 asynchronous or synchronous operation. Abstract nature of the `Task<T>` enforces
 you to create a subclass for any task you want to create. Subclassing `Task<T>`
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
 
	* `Value(T)`
	* `Error(ErrorType)`
 
 After `finish(_:)` method is called, you can access result through `result`
 property.
 
 - note: You can access `result` object from any thread.
 
 **Example subclass**
 
 ```swift
 class SomeTask: Task<Int> {
     override func run() {
         asyncOperation { data, error in
             if error != nil {
                finish(.Error(error!))
             } else {
                finish(.Value(data as! Int))
             }
         }
     }
 }
 
 let queue = TaskQueue()
 let task = SomeTask()
 queue.addTask(task)
 ```
 
 ### **Completion blocks**
 ---
 You can use one of the defined completion blocks that are executed when task
 finished with execution.
 
 1. `onValue` - executed when task finishes with `Value(T)`
 2. `onError` - executed when task finishes with `Error(ErrorType)`
 
 ```swift
 let task = SomeTask()
 
 task
    .onValue { value in
        print(value)
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
 
 task.addDependency(otherTask)
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
 `addCondition(_:)` method.
 
 ### **Observers**
 ---
 
 In addition to the `onValue` and `onError` completion methods, you can use
 `TaskObserver` protocol to be notified when task starts and finishes with
 execution.
 
 Classic example would be creating observer that manages `UIActivityIndicator`
 based on the task execution state.
 
 ### **Retry**
 ---
 
 If the task finishes execution with error, it's execution can be retried. To
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
    
    /**
     Internal result object
     
     - Warning: Should never be set directly, only via `result` property
     */
    fileprivate var internalResult: Result<T>?
    
    /**
     Internal task state
     
     - Warning: Setting the state directly using this property will result
     in unexpected behaviour. Use the `state` property to set and retrieve
     current state.
     */
    fileprivate var internalState: State = .initialized
    
    /**
     Internal completion block
     
     - Warning: Accessing this property directly will result in unexpected behavior.
     Use `onValueBlock` instead.
     */
    fileprivate var internalOnValueBlock: ((T) -> Void)?
    
    /**
     Internal error completion block
     
     - Warning: Accessing this property directly will result in unexpected behavior.
     Use `onErrorBlock` instead.
     */
    fileprivate var internalOnErrorBlock: ((Error) -> Void)?
    
    /**
     Internal task observers
     */
    fileprivate var internalObservers: [TaskObserver] = []
    
    /**
     Internal task conditions
    */
    fileprivate var internalConditions: [TaskCondition] = []
    
    /**
     Internal number of retry counts
     */
    fileprivate var internalRetryCount: Int = 0
    
    /**
     Internal condition errors
    */
    fileprivate var internalConditionErrors = [Error]()
    
    /**
     Private queue used in task state machine
     */
    let queue = DispatchQueue(label: "io.overdrive.task", attributes: [])
    
    //MARK: Class properties
    
    /**
     Task result. Result can contain either value or error.
     
     `Value(T)`: value of type defined by the Task
     
     `Error(ErrorType)`: error that may have occured
     
     This object is not goint to be populated with result until task
     achieves `Finished` state. You can access the result value directly,
     or setup completion blocks that will execute when task finishes.
     */
    internal(set) open var result: Result<T>? {
        get {
            return queue.sync { return internalResult }
        }
        
        set(newResult) {
            queue.sync {
                internalResult = newResult
            }
        }
    }
    
    /**
     Completion block that will be executed when the task finishes execution.
     
     - Warning: **DEPRECATED**. Use `onValue(_:)` method to set completion
     block.
    */
    @available(*, deprecated, message : "use onResult completion instead")
    open override var completionBlock: (() -> Void)? {
        get {
            return nil
        }
        set {
            assert(false, "Use onValue method to define the behaviour")
        }
    }
    
    var retryCount: Int {
        get {
            return queue.sync { return internalRetryCount }
        }
        
        set(newCount) {
            queue.sync {
                internalRetryCount = newCount
            }
        }
    }
    
    //MARK: Completion methods
    
    /**
     Completion block that is executed when the task reaches `Finished` state and
     `.Value` is passed to the `finish:` method. Completion block takes one
     argument `T`, which is `.Value` component from the task result.
     
     See `Result<T>`.
     
     Block should be set by using `onValue:` method on `Self`.
     
     - Warning: Setting this property directly may result in unexpected behaviour.
     Always use `onValue(_:)` method on `Self` to set the block.
     */
    var onValueBlock: ((T) -> Void)? {
        get {
            return queue.sync {
                return internalOnValueBlock
            }
        }
        
        set(newBlock) {
            if newBlock != nil {
                queue.sync {
                    internalOnValueBlock = newBlock
                }
            }
        }
    }
    
    /**
     Completion block that is executed when the task reaches `Finished` state and
     error is passed to the `finish:` method. Completion block has one argument,
     `ErrorType` and no return type. `ErrorType`.
     
     Block should be set by using `onError:` method on `Self`.
     
     - Warning: Setting this property directly may result in unexpected behaviour.
     Always use `onError:` method on `Self` to set the block.
     */
    var onErrorBlock: ((Error) -> Void)? {
        get {
            return queue.sync {
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
    
    /**
     Use this method to set completion block that will be executed when task
     finishes execution with `.Value(T)` result.
     
     - Note: 
     If the task finishes with `.Error` result, onError(_:) method will be called.
     
     - Warning: This method should only be called before the task state becomes `.Pending`.
     Calling this method after `.Pending` state may result in unexpected behaviour.
     
     - Parameter completion: Completion block that should be executed. Takes `T` parameter
     which is extracted from the `.Value(T)` result.
     
     - Returns: `Self`. This method will always return itself, so that it can be used
     in chain with other task methods.
     */
    @discardableResult
    public final func onValue(_ completion: @escaping ((T) -> Void)) -> Self {
        assert(state < .executing, "On complete called after task is executed")
        onValueBlock = completion
        return self
    }
    
    /**
     Use this method to set completion block that will be executed when task
     finishes with error.
     
     - Note: Completion block set will only be executed if the
     task finishes with `.Error` result.
     
     If the task finishes with `.Value` result, onValue completion will be called.
     
     - Warning: This method should only be called before the task state becomes `.Pending`.
     Calling this method after `.Pending` state may result in unexpected behaviour.
     
     - Parameter completion: Completion block that should be executed. Takes only
     one parameter `ErrorType` and no return type.
     
     - Returns: `Self`. This method will always return itself, so that it can be used
     in chain with other task methods.
     */
    @discardableResult
    public final func onError(_ completion: @escaping ((Error) -> ())) -> Self {
        assert(state < .executing, "On complete called after task is executed")
        onErrorBlock = completion
        return self
    }
    
    //MARK: Retry mechanims
    
    /**
     Set retry count. If the task finishes with error, task will be added to the queue
     again until retry count becomes zero.
     
     - Parameter times: Number of times task should be retried if it finishes with error
     
     - Returns: `Self`
     */
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
    
    /**
     Decreases retry count. If retry count is 0, method will throw,
     so it can be used in retry blocks safely.
     */
    func decreaseRetryCount() throws {
        if retryCount > 0 {
            retryCount = retryCount - 1
        } else {
            throw RetryCountError.countIsZero
        }
    }
    
    //MARK: Task conditions
    
    /**
     All task conditions
    */
    fileprivate(set) open var conditions: [TaskCondition] {
        get {
            return queue.sync { return internalConditions }
        }
        
        set(newConditions) {
            queue.sync {
                internalConditions = newConditions
            }
        }
    }
    
    /**
     Any errors that occured during condition evaluation. If this array is populated
     task will finish with execution.
    */
    var conditionErrors: [Error] {
        get {
            return queue.sync { return internalConditionErrors }
        }
        
        set(newErrors) {
            queue.sync {
                internalConditionErrors = newErrors
            }
        }
    }
    
    /**
     Add condition to the task.
     
     - parameter condition: `TaskCondition` to be added
     
     - warning: Task conditions should be added before task starts with execution. Otherwise,
     assertion fail will occur.
    */
    open func addCondition(_ condition: TaskCondition) {
        assert(state < .executing, "Tried to add condition after task started with execution")
        conditions.append(condition)
    }
    
    /**
     Removes condition from the task.
     
     - parameter condition: condition to be removed
     
     - returns: Boolean indicating whether condition was removed
    */
    open func removeCondition(_ condition: TaskCondition) -> Bool {
        assert(state < .executing, "Tried to remove condition after task started with execution")
        let index = conditions.index { $0.conditionName == condition.conditionName }
        if let index = index {
            conditions.remove(at: index)
            return true
        }
        
        return false
    }
    
    /**
     Removes all conditions of given type.
     
     - parameter type: Type conforming to the `TaskCondition` protocol
     
     - returns: Boolean indicating whether condition was removed
    */
    open func removeConditionOfType<T: TaskCondition>(_ type: T.Type) -> Bool {
        assert(state < .executing, "Tried to remove condition after task started with execution")
        var index = [Int]()
        
        for (i, conditionElement) in conditions.enumerated() {
            if type(of: conditionElement) is T.Type {
                index.append(i)
            }
        }
        if index.count > 0 {
            _ = index.map { conditions.remove(at: $0) }
            return true
        } else {
            return false
        }
    }
    
    //MARK: Task observers
    
    /**
     Array of all task observers (read-only).
     
     Contains two observers by default:
     
     1. `FinishBlockObserver` - used to notify TaskQueue that the task is finished
     2. `RetryTaskObserver` - used to notify TaskQueue that the task should retry execution
     
     */
    internal(set) open var observers: [TaskObserver] {
        get {
            return queue.sync { return internalObservers }
        }
        
        set {
            queue.sync {
                internalObservers = newValue
            }
        }
    }
    
    /**
     Adds observer to the task
     
     - parameter observer: observer to be added
    */
    public final func addObserver(_ observer: TaskObserver) {
        assert(state < .executing, "Observer added after task started with execution")
        observers.append(observer)
    }
    
    /**
     Removes task observer from the task observers.
     
     - Parameter observer: Task observer instance to be removed
     
     - Returns: Boolean indicating whether observer is removed
     
     - Warning: Observer removal should be done before task is added to the `TaskQueue`
     */
    open func removeObserver(_ observer: TaskObserver) -> Bool {
        assert(state < .executing, "Observer removed after task is added to the task queue")
        let indexOfObserver = observers.index { $0.observerName == observer.observerName }
        guard indexOfObserver != nil else {
            return false
        }
        observers.remove(at: indexOfObserver!)
        return true
    }
    
    /**
     Remove all task observers of the defined TaskObserver type. This method will enumerate
     through all task observers, check their type and if the type matches the passed type,
     observer will be removed.
     
     - Parameter type: TaskObserver type
     
     - Returns: Boolean indicating whether observer is removed
     
     - Warning: Observer removal should be done before task is added to the `TaskQueue`
     
     **Example**
     
     ```swift
     let myObserver = CustomObserver()
     task.addObserver(myObserver)
     
     task.removeObserverOfType(CustomObserver)
     ```
     */
    open func removeObserverOfType<T: TaskObserver>(_ type: T.Type) -> Bool {
        assert(state < .executing, "Observer removed after task is added to the task queue")
        var index = [Int]()
        
        for (i, observerElement) in observers.enumerated() {
            if type(of: observerElement) is T.Type {
                index.append(i)
            }
        }
        
        if index.count > 0 {
            _ = index.map { observers.remove(at: $0) }
            return true
        }
        return false
    }
    
    //MARK: State management
    
    /**
     Finish execution of the task with result. Calling this method will change
     task state to `Finished` and call neccesary completion blocks. If task finished
     with `Value(T)`, `onValueBlock` will be executed. If task finished with
     `Error(ErrorType)` result, `onErrorBlock` will be executed.
     
     - Parameter result: Task result (`.Value(T)` or `.Error(ErrorType)`)
     
     - Note:
     Safe to call from any thread.
     */
    public final func finish(_ result: Result<T>) {
        if shouldRetry {
            attemptRetry()
        } else {
            self.result = result
            
            moveToFinishedState()
            
            switch result {
            case .Value(let value):
                onValueBlock?(value)
            case .Error(let error):
                onErrorBlock?(error)
            }
        }
    }
    
    /**
     Main task state object. Any state change triggers internal `NSOperation` observers.
     
     State can be one of the following:
     
     * `Initialized`
     * `Pending`
     * `Ready`
     * `Executing`
     * `Finished`
     
     - Note:
     You can change state from any thread.
     */
    var state: State {
        get {
            return queue.sync { return internalState }
        }
        
        set(newState) {
            
            // Notify internal `NSOperation` observers that state will be changed
            willChangeValue(forKey: "state")
            
            queue.sync {
                assert(internalState.canTransitionToState(newState, shouldRetry: shouldRetry),
                       "Invalid state transformation")
                internalState = newState
            }
            
            // Notifity internal `NSOperation` observers that state is changed
            didChangeValue(forKey: "state")
        }
    }
    
    /**
     This method changes state of `self` to `Pending`. It is called when task is
     added to the `TaskQueue`.
     */
    final func willEnqueue() {
        state = .pending
    }
    
    /**
     Used to notify `NSOperation` superclass that task execution is asynchronous.
     Defaults to `true`.
    */
    public final override var isAsynchronous: Bool {
        return true
    }
    
    /**
     Boolean value indicating Task readiness value
    */
    public final override var isReady: Bool {
        switch state {
        case .initialized:
            return isCancelled
        case .pending:
            guard !isCancelled else {
                return true
            }
            
            if super.isReady {
                evaluateConditions()
            }
            return false
        case .ready:
            return super.isReady || isCancelled
        default:
            return false
        }
    }
    
    /**
     Boolean value indicating Task execution status.
    */
    public final override var isExecuting: Bool {
        return state == .executing
    }
    
    /**
     Boolean value indicating if task finished with execution.
     */
    public final override var isFinished: Bool {
        return state == .finished
    }
    
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
    
    /**
     Changes task state to `Finished`
     */
    internal final func moveToFinishedState() {
        state = .finished
        
        for observer in observers {
            observer.taskDidFinishExecution(self)
        }
    }
    
    //MARK: Task execution
    
    /**
     Starts task execution process when task reaches `Ready` state.
     Non-overridable.
    */
    public override final func start() {
        if isCancelled {
            moveToFinishedState()
        } else if conditionErrors.count > 0 {
            finish(.Error(TaskConditionError.combined(errors: conditionErrors)))
        } else {
            main()
        }
    }
    
    /**
     Starts task execution. Called by the `start()` method. If the task is
     cancelled it will move to finished state.
     Non-overridable.
    */
    public override final func main() {
        assert(state == .ready, "Task must be performed on TaskQueue")
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
    
    /**
     You must override this method in order to provide execution point for the
     task. In order to notify task that the task execution finished, call `finish(_:)`
     method on self.
    */
    open func run() {
        assertionFailure("run() method should be overrided in \(type(of: self))")
    }
    
    /**
     Creates new instance of `Task<T>`
    */
    public override init() {
        super.init()
    }
    
    //MARK: KVO mechanisms
    
    /**
     Called by `NSOperation` KVO mechanisms to check if task is ready
    */
    @objc class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    /**
     Called by `NSOperation` KVO mechanisms to check if task is executing
     */
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    /**
     Called by `NSOperation` KVO mechanisms to check if task is finished
     */
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    //MARK: Dependency management
    
    open override func addDependency(_ operation: Operation) {
        assert(state < .executing)
        
        super.addDependency(operation)
    }
    
    /**
     Returns dependency instance from the task dependencies.
     
     - Parameter type: Dependency Task type
     
     - Returns: Optional `Task<T>` dependency instance
     
     ### Example
     ```swift
     let dependencyTask = SomeTask()
     if let dependency = task.getDependency(SomeTask) {
        print(dependency) // dependencyTask instance
     }
     ```
     */
    open func getDependency<T>(_ type: Task<T>.Type) -> Task<T>? {
        let filteredDependency = dependencies.filter { $0 as? Task<T> != nil }
        return filteredDependency.first as? Task<T>
    }
}

/**
 Defines errors that can be thrown in task retry process
 */
enum RetryCountError: Error {
    case countIsZero
}
