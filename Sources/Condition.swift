//
//  Condition.swift
//  Overdrive
//
//  Created by Said Sikira on 6/25/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

public enum TaskConditionResult {
    case Satisfied
    case Failed(ErrorType)
    
    var error: ErrorType? {
        if case .Failed(let error) = self {
            return error
        }
        return nil
    }
}

public protocol TaskCondition {
    func dependency<T, U>(forTask task: Task<T>) -> Task<U>?
    func evaluate<T>(forTask task: Task<T>, evaluationBlock: (TaskConditionResult -> Void))
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
