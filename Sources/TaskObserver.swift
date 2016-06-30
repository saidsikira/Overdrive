//
//  TaskObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

//MARK: - TaskObserver protocol definition

/**
 Protocol that types implement in order to be notified of significant events
 in task lifecycle.
*/
public protocol TaskObserver {
    
    /**
     Notifies reciever that task began execution
     
     - Parameter task: Task that started execution
    */
    func taskDidStartExecution<T>(task: Task<T>)
    
    /**
     Notifies reciever that task finished execution
     
     - Parameter task: Task that finished execution
    */
    func taskDidFinishExecution<T>(task: Task<T>)
}

//MARK: - TaskObserver default implementations

extension TaskObserver {
    
    /// Observer name, returns conforming type name (read-only)
    public var observerName: String {
        return String(self.dynamicType)
    }
    
    public func taskDidStartExecution<T>(task: Task<T>) {
    }
    
    public func taskDidFinishExecution<T>(task: Task<T>) {
    }
}

//MARK: - Task extensions

extension Task {
    /**
     Removes task observer from the task observers.
     
     - Parameter observer: Task observer instance to be removed
     
     - Returns: Boolean indicating whether observer is removed
     
     - Warning: Observer removal should be done before task is added to the `TaskQueue`
     */
    public func remove(observer observer: TaskObserver) -> Bool {
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
}
