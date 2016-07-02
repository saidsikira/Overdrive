//
//  Condition.swift
//  Overdrive
//
//  Created by Said Sikira on 6/25/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Defines task condition result that is returned in the process of evaluating
 conditions. Can be `Satisfied` or `Failed(ErrorType)`
*/
public enum TaskConditionResult {
    
    /// Task conditions is satisfied
    case Satisfied
    
    /// Task condition failed with error
    case Failed(ErrorType)
    
    /// If result is failed, associated error will be returned
    var error: ErrorType? {
        if case .Failed(let error) = self {
            return error
        }
        return nil
    }
}

/**
 Defines errors that can be thrown when condition evaluation finishes
*/
public enum TaskConditionError: ErrorType {
    
    /// Combined errors
    case Combined(errors: [ErrorType])
}

/**
 Defines protocol that can be used to define conditions that should be satisfied in order
 to run a task. Task conditions manage custom task dependencies and evaluation for the task.
*/
public protocol TaskCondition {
    
    /**
     Condition name. Defaults to conforming instance name
    */
    var conditionName: String { get }
    
    /**
     If task needs a dependency to execute first, you should return it in this method. For example,
     some tasks need OS premissions to execute. For example location services, photo retrieval,
     camera use etc. By using this method you can setup a dependency that can validate status of 
     those premissions.
     
     - Parameter forTask: That that conditions are being evaluated for
     
     - Returns: `Task<U>` Any task instance
    */
    func dependency<T, U>(forTask task: Task<T>) -> Task<U>?
    
    /**
     Evaluates condition for the task. Evaluation can be any asynchronous process. When evaluation
     process is done evaluationBlock callback should be called with appropriate `TaskConditionResult`.
     
     - Note: This method does not guarantee that evaluation will be done on the main thread. If you want
     to evaluate condition on the main thread, use `dispatch_async` call.
    */
    func evaluate<T>(forTask task: Task<T>, evaluationBlock: (TaskConditionResult -> Void))
}

extension TaskCondition {
    
    /// Returns nil
    func dependency<T, U>(forTask task: Task<T>) -> Task<U>? {
        return nil
    }
    
    public var conditionName: String {
        return "\(self.dynamicType)"
    }
}

struct TaskConditionEvaluator {
    static func evaluate<T>(conditions: [TaskCondition], forTask task: Task<T>, completion: (([ErrorType]) -> Void)) {
        let conditionGroup = dispatch_group_create()
        
        var results = [TaskConditionResult?](count: conditions.count, repeatedValue: nil)
        
        for (index, condition) in conditions.enumerate() {
            dispatch_group_enter(conditionGroup)
            condition.evaluate(forTask: task) {
                result in
                results[index] = result
                dispatch_group_leave(conditionGroup)
            }
        }
        
        dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            let failures = results.flatMap { $0?.error }
            
            completion(failures)
        }
    }
}
