//
//  InlineTask.swift
//  Overdrive
//
//  Created by Said Sikira on 7/7/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 `InlineTask` provides interface for creating asynchronous taks that don't
 neccesarily finish with result. To create `InlineTask` you pass a closure to
 the initializer.
 
 ```swift
 let task = InlineTask {
 doWork()
 }
 ```
 
 Inline tasks behave same as any `Task<T>`. They can be added to the
 `TaskQueue` and you can use `onComplete(_:)` method to be notified when they
 are finished with execution.
 
 - Note: `InlineTask` is most commonly used in UI interactions. For example,
 you can create `InlineTask` that presents view controller and add dependency
 task that retrieves data from the server.
*/
public class InlineTask: Task<Void> {
    
    private var internalTaskBlock: ((Void -> Void) -> Void)?
    
    var taskBlock: ((Void -> ()) -> ())? {
        get { return Dispatch.sync(queue) { return self.internalTaskBlock } }
        
        set(newBlock) {
            Dispatch.sync(queue) {
                self.internalTaskBlock = newBlock
            }
        }
    }
    
    /**
     Initializes `InlineTask` with closure block. 
     
     - Parameter taskBlock: block that will be executed when task is added to the TaskQueue.
    */
    public init(_ taskBlock: Void -> ()) {
        super.init()
        self.taskBlock = { void in
            taskBlock()
            void()
        }
    }
    
    /// Starts execution of the task
    public override func run() {
        taskBlock? { void in
            self.finish(.Value(void))
        }
    }
}
