//
//  Condition.swift
//  Overdrive
//
//  Created by Said Sikira on 6/25/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

//MARK: - TaskConditionResult enum

/**
 Defines task condition result that is returned in the process of evaluating
 conditions. Can be `Satisfied` or `Failed(ErrorType)`
*/
public enum TaskConditionResult {
    
    /// Task conditions is satisfied
    case satisfied
    
    /// Task condition failed with error
    case failed(Error)
    
    /// If result is failed, associated error will be returned
    var error: Error? {
        if case .failed(let error) = self {
            return error
        }
        return nil
    }
}

//MARK: - TaskConditionError enum

/**
 Defines errors that can be thrown when condition evaluation finishes
*/
public enum TaskConditionError: Error {
    
    /// Combined errors
    case combined(errors: [Error])
}

//MARK: - TaskCondition protocol

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
     If task needs a dependency to execute, you should return it in this method. For example,
     some tasks need OS permissions to do work (location services etc.) and requests for those
     permissions can be exposed as dependencies.
     
     - Parameter forTask: That that conditions are being evaluated for
     
     - Returns: Any `NSOperation` or instance of any `Task<T>`
    */
    func dependencies<T>(forTask task: Task<T>) -> [Operation]
    
    /**
     Evaluates condition for the task. Evaluation can be any asynchronous process. When evaluation
     process is done `evaluationBlock` callback should be called with appropriate `TaskConditionResult`.
     
     - Note: This method does not guarantee that evaluation will be done on the main thread. If you want
     to evaluate condition on the main thread, use `dispatch_async` call.
    */
    func evaluate<T>(forTask task: Task<T>, evaluationBlock: ((TaskConditionResult) -> Void))
}

extension TaskCondition {
    
    /// Default implementation. Returns `nil`.
    func dependencies<T>(forTask task: Task<T>) -> [Operation] {
        return []
    }
    
    public var conditionName: String {
        return "\(type(of: self))"
    }
}

//MARK: - Task Condition Evaluator

/**
 `TaskConditionEvaluator` is used to evaluate task conditions for specific task.
*/
struct TaskConditionEvaluator {
    
    /**
     Evaluates conditions for defined task. This method will report evaluation process results with
     completion block.
     
     - parameter conditions: Array of `TaskCondition` instances
     - parameter forTask: Task for which conditions are evaluated for
     - parameter completion: Completion block that runs after conditions are evaluated.
    */
    static func evaluate<T>(_ conditions: [TaskCondition], forTask task: Task<T>, completion: @escaping (([Error]) -> Void)) {
        let conditionGroup = DispatchGroup()
        
        var results = [TaskConditionResult?](repeating: nil, count: conditions.count)
        
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluate(forTask: task) {
                result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        conditionGroup.notify(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default)) {
            let failures = results.flatMap { $0?.error }
            
            completion(failures)
        }
    }
}
