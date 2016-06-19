//
//  Task.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation

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
    private(set) public var result: Result<T>? {
        get {
            return Dispatch.sync(queue) { return self.internalResult }
        }
        
        set(newResult) {
            Dispatch.sync(queue) {
                self.internalResult = newResult
            }
        }
    }
    
    /// Completion block that will be executed when the task finishes execution
    @available(*, deprecated, message = "use onResult completion instead")
    public override var completionBlock: (() -> Void)? {
        get {
            return nil
        }
        set {
            assert(false, "Use onComplete method to define the behaviour")
        }
    }
    
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
    
    public final func onComplete(completion: ((T) -> ())) -> Self {
        onCompleteBlock = completion
        return self
    }
    
    public final func onError(completion: ((ErrorType) -> ())) -> Self {
        onErrorBlock = completion
        return self
    }
    
    var state: State {
        get {
            return Dispatch.sync(queue) { return self.internalState }
        }
        
        set(newState) {
            
            willChangeValueForKey("state")
            
            Dispatch.sync(queue) {
                assert(self.internalState.canTransitionToState(newState),
                       "Invalid state transformation")
                self.internalState = newState
            }
            
            didChangeValueForKey("state")
        }
    }
    
    final func willEnqueue() {
        state = .Pending
    }
    
    public override var asynchronous: Bool {
        return true
    }
    
    public override var ready: Bool {
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
    
    public override var executing: Bool {
        return state == .Executing
    }
    
    public override var finished: Bool {
        return state == .Finished
    }
    
    final func evaluateConditions() {
        assert(state == .Pending && !cancelled, "evaluateConditions() was called out-of-order")
        
        state = .Ready
    }
    
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
    
    private final func moveToFinishedState() {
        state = .Finished
    }
    
    public override final func start() {
        if cancelled {
            moveToFinishedState()
        } else {
            main()
        }
    }
    
    public override final func main() {
        assert(state == .Ready, "Task must be performed on OperationQueue")
        state = .Executing
        
        if !cancelled {
            run()
        } else {
            moveToFinishedState()
        }
    }
    
    public func run() {
        assertionFailure("run() method should be overrided in \(self.dynamicType)")
    }
    
    public override init() {
        super.init()
    }
    
    //MARK: KVO mechanisms
    
    @objc class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
}
