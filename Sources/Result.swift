//
//  Result.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Task result definition.
 
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
