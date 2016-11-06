//
//  InlineTask.swift
//  Overdrive
//
//  Created by Said Sikira on 7/7/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

public typealias InlineTaskBase = Task<Void>

/// `InlineTask` provides interface for creating asynchronous taks that don't
/// neccesarily finish with result. To create `InlineTask` you pass a closure to
/// the initializer.
///
/// ```swift
/// let task = InlineTask {
///    doWork()
/// }
/// ```
///
/// Inline tasks behave same as any `Task<T>`. They can be added to the
/// `TaskQueue` and you can use `onValue(_:)` method to be notified when they
/// are finished with execution.
///
/// - Note: `InlineTask` is most commonly used in UI interactions. For example,
/// you can create `InlineTask` that presents view controller and add dependency
/// task that retrieves data from the server.
open class InlineTask: InlineTaskBase {
    
    fileprivate var internalTaskBlock: (((Void) -> ()) -> ())?
    
    /// Sets task block
    ///
    /// - parameter taskBlock: Block to be executed
    fileprivate func set(taskBlock: @escaping ((Void) -> (Void)) -> Void) {
        queue.sync {
            internalTaskBlock = taskBlock
        }
    }
    
    var taskBlock: (((Void) -> ()) -> ())? {
        get { return queue.sync { return internalTaskBlock } }
    }
    
    /// Initializes `InlineTask` with closure block.
    ///
    /// - Parameter taskBlock: block that will be executed when task is added to the TaskQueue.
    public init(_ taskBlock: @escaping (Void) -> ()) {
        super.init()
        set(taskBlock: { void in
            taskBlock()
            void()
        })
    }
    
    /// Starts execution of the task
    open override func run() {
        taskBlock? { void in
            self.finish(with: .value(void))
        }
    }
}
