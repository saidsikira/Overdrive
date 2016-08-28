//
//  Result.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Task result definition. `Result<T>` is one of the fundamental concepts in
 Task execution. To finish execution of any task, you need to pass the Result
 to the `finish(_:)` method.
 
 `Result<T>` enum definition defines two cases:
 
 * `Value(T)`
 * `Error(ErrorType)`
 
 
 **Example**
 
 ```swift
 var intResult: Result<Int> = .Value(10)
 intResult = .Error(someError)
 ```
*/
public enum Result<T> {
    
    /// Value with associated type `T`
    case Value(T)
    
    /// Error case with associated `ErrorType`
    case Error(ErrorType)
    
    //MARK: Init methods
    
    init(_ value: T) {
        self = .Value(value)
    }
    
    init(_ error: ErrorType) {
        self = .Error(error)
    }
    
    //MARK: Associated values
    
    /// Returns value `T`
    public var value: T? {
        if case .Value(let value) = self {
            return value
        }
        return nil
    }
    
    /// Returns error value
    public var error: ErrorType? {
        if case .Error(let error) = self {
            return error
        }
        return nil
    }
}

extension Result {
    
    /**
     Returns transformed Result<U>
    */
    @warn_unused_result
    public func map<U>(@noescape transform: (T) -> U) -> Result<U> {
        switch self {
        case .Value(let value):
            return Result<U>.Value(transform(value))
        case .Error(let error):
            return Result<U>.Error(error)
        }
    }
}

extension Result: CustomStringConvertible {
    
    /// Returns textual representation of `self`
    public var description: String {
        switch self {
        case .Value(let value):
            return "\(value)"
        case .Error(let error):
            return "\(error)"
        }
    }
}
