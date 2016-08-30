//
//  TaskError.swift
//  Overdrive
//
//  Created by Said Sikira on 8/28/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

/*
 Defines errors that can be used in test environment
*/
enum TaskError: ErrorType {
    
    /// Regular error with message
    case fail(String )
    
    /// Type erased combined errors
    case combined([ErrorType])
}