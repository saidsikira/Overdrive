//
//  Task.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation

/**
 Provides thread-safe, concurrent and asynchronous execution of any task,
 by utilizing `NSOperation` and `GCD` mechanisms. `Task` provides type-safe
 execution by defining concrete type that will be task result object.
 
 To execute the task you must add it to the `TaskQueue` queue which manages
 task execution, task dependencies, retry operations and concurrency.
 
 `Task` also provides method chaining and completion blocks that are executed 
 depending on the task result. It also features retry mechanisms for tasks
 which finished with errors.
 
 Since `Task<T>` is an abstract class you should always create subclass or 
 use concrete `TaskBlock` subclass. Subclassing `Task<T>` is simple operation. 
 You are only required to override `run()` method that defines task execution 
 point and call `finish(_:)` method to notify task that execution is finished.
 
 **Example task**
 ---
 
 ```swift
 // Defines `CustomTask` subclass that exposes `Int` result
 class CustomTask: Task<Int> {
    override func run() {
        asyncTask { result, error in
            if error != nil {
                finish(.Error(error!))
            } else {
                finish(.Value(resut as! Int))
            }
        }
    }
 }
 ```
 
 ### **Finishing task execution**
 ---
 
 Since you can wrap any synchronous or asynchronous task inside `run()` method,
 you must call `finish(_:)` method with `Result<T>` enum object to popuplate the 
 task result and notify `TaskQueue` that the task finished with execution.
 
 Task result is exposed as `Result<T>` enum which can have one of the following
 cases:
 
 * `Value(T)` - Value associated with the task returning type
 * `Error(ErrorType)` - Error that may occur during task execution
 
 After task finishes execution, you can access the result via `result` property.
 
 - Note: You can access `result` object from any thread.
 
 If the task is asynchronous, `result` instance may be `nil` since `finish(_:)`
 method is not called yet. In that case you should use `onComplete(_:)` and `onError(_:)`
 methods.
 
 **Example**
 
 ```swift
 let task = CustomTask()
 task
    .onComplete { value in
        print(value)
     }
    .onError { error in
        prin(error)
 }
 
 TaskQueue.main.addTask(task)
 ```
 
 - Warning:
 Calling `onComplete` and `onError` method after the task is added to the `TaskQueue`
 may result in error, since the task may have already finished with result. To avoid
 this behaviour, always call these methods before task is added to the `TaskQueue`.
 
 ### **Dependencies**
 ---
 
 You can use task dependencies to ensure correct task order execution. If task has 
 any dependencies, `TaskQueue` will first execute them first and if they finish
 without errors, parent task will be executed.
 
 You can add dependencies by using `addDependency(_:)` method.
 
 **Example dependency**
 
 ```swift
 let getDataTask = GetDataTask()
 let parseJSONTask = ParseJSONTask()
 
 parseJSONTask.addDependency(getDataTask)
 TaskQueue.main.addTask(parseJSONTask)
 ```
 
 - Warning:
 You should create dependency tree before task is added to the `TaskQueue`.
 
*/
public class Task<T>: NSOperation {
    
    /**
     Internal result object
     
     - Warning: Should never be set directly, only via `result` property
     */
    private var internalResult: Result<T>?
    
    /**
     Internal task state
     
     - Warning: Setting the state directly using this property will result
     in unexpected behaviour. Use the `state` property to set and retrieve
     current state.
     */
    private var internalState: State = .Initialized
    
    /**
     Internal completion block
     
     - Warning: Accessing this property directly will result in unexpected behavior.
     Use `onCompleteBlock` instead.
     */
    private var internalOnCompleteBlock: ((T) -> Void)?
    
    /**
     Internal error completion block
     
     - Warning: Accessing this property directly will result in unexpected behavior.
     Use `onErrorBlock` instead.
     */
    private var internalOnErrorBlock: ((ErrorType) -> Void)?
    
    /**
     Internal task observers
     */
    private var internalObservers: [TaskObserver] = []
    
    /**
     Internal task conditions
    */
    private var internalConditions: [TaskCondition] = []
    
    /**
     Internal number of retry counts
     */
    private var internalRetryCount: Int = 0
    
    /**
     Private queue used in task state machine
     */
    let queue = dispatch_queue_create("io.overdrive.task", nil)
    
    //MARK: Class properties
    
    /**
     Task result. Result can contain either value or error.
     
     `Value(T)`: value of type defined by the Task
     
     `Error(ErrorType)`: error that may have occured
     
     This object is not goint to be populated with result until task
     achieves `Finished` state. You can access the result value directly,
     or setup completion blocks that will execute when task finishes.
     */
    internal(set) public var result: Result<T>? {
        get {
            return Dispatch.sync(queue) { return self.internalResult }
        }
        
        set(newResult) {
            Dispatch.sync(queue) {
                self.internalResult = newResult
            }
        }
    }
    
    /**
     Completion block that will be executed when the task finishes execution.
     
     - Warning: **DEPRECATED**. Use `onComplete(_:)` method to set completion
     block.
    */
    @available(*, deprecated, message = "use onResult completion instead")
    public override var completionBlock: (() -> Void)? {
        get {
            return nil
        }
        set {
            assert(false, "Use onComplete method to define the behaviour")
        }
    }
    
    var retryCount: Int {
        get {
            return Dispatch.sync(queue) { return self.internalRetryCount }
        }
        
        set(newCount) {
            Dispatch.sync(queue) {
                self.internalRetryCount = newCount
            }
        }
    }
    
    //MARK: Completion methods
    
    /**
     Completion block that is executed when the task reaches `Finished` state and
     `.Value` is passed to the `finish:` method. Completion block takes one
     argument `T`, which is `.Value` component from the task result.
     
     See `Result<T>`.
     
     Block should be set by using `onComplete:` method on `Self`.
     
     - Warning: Setting this property directly may result in unexpected behaviour.
     Always use `onComplete(_:)` method on `Self` to set the block.
     */
    var onCompleteBlock: ((T) -> Void)? {
        get {
            return Dispatch.sync(queue) {
                return self.internalOnCompleteBlock
            }
        }
        
        set(newBlock) {
            if newBlock != nil {
                Dispatch.sync(queue) {
                    self.internalOnCompleteBlock = newBlock
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
    var onErrorBlock: ((ErrorType) -> Void)? {
        get {
            return Dispatch.sync(queue) {
                return self.internalOnErrorBlock
            }
        }
        
        set(newBlock) {
            if newBlock != nil {
                Dispatch.sync(queue) {
                    self.internalOnErrorBlock = newBlock
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
    public final func onComplete(completion: ((T) -> Void)) -> Self {
        assert(state < .Executing, "On complete called after task is executed")
        onCompleteBlock = completion
        return self
    }
    
    /**
     Use this method to set completion block that will be executed when task
     finishes with error.
     
     - Note: Completion block set will only be executed if the
     task finishes with `.Error` result.
     
     If the task finishes with `.Value` result, onComplete completion will be called.
     
     - Warning: This method should only be called before the task state becomes `.Pending`.
     Calling this method after `.Pending` state may result in unexpected behaviour.
     
     - Parameter completion: Completion block that should be executed. Takes only
     one parameter `ErrorType` and no return type.
     
     - Returns: `Self`. This method will always return itself, so that it can be used
     in chain with other task methods.
     */
    public final func onError(completion: ((ErrorType) -> ())) -> Self {
        assert(state < .Executing, "On complete called after task is executed")
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
    public func retry(times: Int) -> Self {
        retryCount = times
        return self
    }
    
    //MARK: Task conditions
    
    /**
     All task conditions
    */
    private(set) public var conditions: [TaskCondition] {
        get {
            return Dispatch.sync(queue) { return self.internalConditions }
        }
        
        set(newConditions) {
            Dispatch.sync(queue) {
                self.internalConditions = newConditions
            }
        }
    }
    
    /**
     Add condition to the task.
     
     - parameter condition: `TaskCondition` to be added
     
     - warning: Task conditions should be added before task starts with execution. Otherwise,
     assertion fail will occur.
    */
    public func addCondition(condition: TaskCondition) {
        assert(state < .Executing, "Tried to add condition after task started with execution")
        conditions.append(condition)
    }
    
    /**
     Removes condition from the task.
     
     - parameter condition: condition to be removed
     
     - returns: Boolean indicating whether condition was removed
    */
    public func removeCondition(condition: TaskCondition) -> Bool {
        assert(state < .Executing, "Tried to remove condition after task started with execution")
        let index = conditions.indexOf { $0.conditionName == condition.conditionName }
        if let index = index {
            conditions.removeAtIndex(index)
            return true
        }
        
        return false
    }
    
    /**
     Removes all conditions of given type.
     
     - parameter type: Type conforming to the `TaskCondition` protocol
     
     - returns: Boolean indicating whether condition was removed
    */
    public func removeConditionOfType<T: TaskCondition>(type: T.Type) -> Bool {
        assert(state < .Executing, "Tried to remove condition after task started with execution")
        var index = [Int]()
        
        for (i, conditionElement) in conditions.enumerate() {
            if conditionElement.dynamicType is T.Type {
                index.append(i)
            }
        }
        if index.count > 0 {
            _ = index.map { conditions.removeAtIndex($0) }
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
    internal(set) public var observers: [TaskObserver] {
        get {
            return Dispatch.sync(queue) { return self.internalObservers }
        }
        
        set {
            Dispatch.sync(queue) {
                self.internalObservers = newValue
            }
        }
    }
    
    /**
     Adds observer to the task
     
     - parameter observer: observer to be added
    */
    public final func addObserver(observer: TaskObserver) {
        assert(state < .Executing, "Observer added after task started with execution")
        observers.append(observer)
    }
    
    /**
     Removes task observer from the task observers.
     
     - Parameter observer: Task observer instance to be removed
     
     - Returns: Boolean indicating whether observer is removed
     
     - Warning: Observer removal should be done before task is added to the `TaskQueue`
     */
    public func removeObserver(observer: TaskObserver) -> Bool {
        assert(state < .Executing, "Observer removed after task is added to the task queue")
        let indexOfObserver = observers.indexOf { $0.observerName == observer.observerName }
        guard indexOfObserver != nil else {
            return false
        }
        observers.removeAtIndex(indexOfObserver!)
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
    public func removeObserverOfType<T: TaskObserver>(type: T.Type) -> Bool {
        assert(state < .Executing, "Observer removed after task is added to the task queue")
        var index = [Int]()
        
        for (i, observerElement) in observers.enumerate() {
            if observerElement.dynamicType is T.Type {
                index.append(i)
            }
        }
        
        if index.count > 0 {
            _ = index.map { observers.removeAtIndex($0) }
            return true
        }
        return false
    }
    
    //MARK: State management
    
    /**
     Finish execution of the task with result. Calling this method will change
     task state to `Finished` and call neccesary completion blocks. If task finished
     with `Value(T)`, `onCompleteBlock` will be executed. If task finished with
     `Error(ErrorType)` result, `onErrorBlock` will be executed.
     
     - Parameter result: Task result (`.Value(T)` or `.Error(ErrorType)`)
     
     - Note:
     Safe to call from any thread.
     */
    public final func finish(result: Result<T>) {
        self.result = result
        moveToFinishedState()
        
        switch result {
        case .Value(let value):
            onCompleteBlock?(value)
        case .Error(let error):
            onErrorBlock?(error)
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
            return Dispatch.sync(queue) { return self.internalState }
        }
        
        set(newState) {
            
            // Notify internal `NSOperation` observers that state will be changed
            willChangeValueForKey("state")
            
            Dispatch.sync(queue) {
                assert(self.internalState.canTransitionToState(newState, shouldRetry: self.shouldRetry),
                       "Invalid state transformation")
                self.internalState = newState
            }
            
            // Notifity internal `NSOperation` observers that state is changed
            didChangeValueForKey("state")
        }
    }
    
    /**
     This method changes state of `self` to `Pending`. It is called when task is
     added to the `TaskQueue`.
     */
    final func willEnqueue() {
        state = .Pending
    }
    
    /**
     Used to notify `NSOperation` superclass that task execution is asynchronous.
     Defaults to `true`.
    */
    public final override var asynchronous: Bool {
        return true
    }
    
    /**
     Boolean value indicating Task readiness value
    */
    public final override var ready: Bool {
        switch state {
        case .Initialized:
            return cancelled
        case .Pending:
            guard !cancelled else {
                return true
            }
            
            if super.ready {
                evaluateConditions()
            }
            return false
        case .Ready:
            return super.ready || cancelled
        default:
            return false
        }
    }
    
    /**
     Boolean value indicating Task execution status.
    */
    public final override var executing: Bool {
        return state == .Executing
    }
    
    /**
     Boolean value indicating if task finished with execution.
     */
    public final override var finished: Bool {
        return state == .Finished
    }
    
    final func evaluateConditions() {
        assert(state == .Pending && !cancelled, "evaluateConditions() was called out-of-order")
        
        state = .Ready
    }
    
    /**
     Changes task state to `Finished`
     */
    internal final func moveToFinishedState() {
        state = .Finished
        
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
        if cancelled {
            moveToFinishedState()
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
        assert(state == .Ready, "Task must be performed on TaskQueue")
        state = .Executing
        
        for observer in observers {
            observer.taskDidStartExecution(self)
        }
        
        if !cancelled {
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
    public func run() {
        assertionFailure("run() method should be overrided in \(self.dynamicType)")
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
        return ["state"]
    }
    
    /**
     Called by `NSOperation` KVO mechanisms to check if task is executing
     */
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    /**
     Called by `NSOperation` KVO mechanisms to check if task is finished
     */
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
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
            throw RetryCountError.CountIsZero
        }
    }
    
    //MARK: Dependency management
    
    public override func addDependency(operation: NSOperation) {
        assert(state < .Executing)
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
    public func getDependency<T>(type: Task<T>.Type) -> Task<T>? {
        let filteredDependency = dependencies.filter { $0 as? Task<T> != nil }
        return filteredDependency.first as? Task<T>
    }
}

/**
 Defines errors that can be thrown in task retry process
 */
enum RetryCountError: ErrorType {
    case CountIsZero
}
