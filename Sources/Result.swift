//
//  Result.swift
//  Overdrive
//
//  Created by Said Sikira on 6/19/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

public enum Result<T> {
    case Value(T)
    case Error(ErrorType)
}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Value(let value):
            return "Value \(value)"
        case .Error(let error):
            return "Error \(error)"
        }
    }
}
