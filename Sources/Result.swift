//
//  Result.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

/**
 Task enum result definition.
 
 **Example**
 
 ```swift
 let intResult: Result<Int> = .Value(10)
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
            return "Value \(value)"
        case .Error(let error):
            return "Error \(error)"
        }
    }
}
