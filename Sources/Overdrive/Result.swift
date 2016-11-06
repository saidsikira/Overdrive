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
    case value(T)
    
    /// Error case with associated `ErrorType`
    case error(Error)
    
    // MARK: Init methods
    
    init(_ value: T) {
        self = .value(value)
    }
    
    init(_ error: Error) {
        self = .error(error)
    }
    
    // MARK: Associated values
    
    /// Returns value `T`
    public var value: T? {
        if case .value(let value) = self {
            return value
        }
        return nil
    }
    
    /// Returns error value
    public var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}

extension Result {
    
    /// Maps over result
    ///
    /// - parameter transform: transform block
    ///
    /// - returns: `Result<T>`
    public func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case .value(let value):
            return Result<U>.value(transform(value))
        case .error(let error):
            return Result<U>.error(error)
        }
    }
}

extension Result: CustomStringConvertible {
    
    /// Returns textual representation of `self`
    public var description: String {
        switch self {
        case .value(let value):
            return "\(value)"
        case .error(let error):
            return "\(error)"
        }
    }
}
