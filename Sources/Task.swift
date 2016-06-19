//
//  Task.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation

public class Task<T>: NSOperation {
    @objc class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
    
    let queue = dispatch_queue_create("io.overdrive.task", nil)
    
    var internalResult: Result<T>?
    
    public var result: Result<T>? {
        get {
            return Dispatch.sync(queue) {
                return self.internalResult
            }
        }
        
        set(newResult) {
            Dispatch.sync(queue) {
                self.internalResult = newResult
            }
        }
    }
    
    @available(*, deprecated, message = "use onResult completion instead")
    public override var completionBlock: (() -> Void)? {
        get {
            return nil
        }
        set {
            assert(false, "Use onComplete completion block instead of completionBlock")
        }
    }
    
    //MARK: Completion blocks
    private var internalOnCompleteBlock: ((T) -> Void)?
    private var internalOnErrorBlock: ((ErrorType) -> Void)?
    
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
    
    var internalState: State = .Initialized
    
    var state: State {
        get {
            return Dispatch.sync(queue) { return self.internalState }
        }
        
        set(newState) {
            
            willChangeValueForKey("state")
            
            Dispatch.sync(queue) {
                assert(self.internalState.canTransitionToState(newState), "Invalid state transformation")
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
}