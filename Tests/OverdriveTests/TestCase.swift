//
//  TestCase.swift
//  Overdrive
//
//  Created by Said Sikira on 11/24/16.
//
//

import Foundation
import XCTest
import Overdrive

// MARK: - TestCaseTask

/// Special `Task<T>` subclass that is used in test enviroment
/// in cases where task result should be defined at initialization
/// stage.
class TestCaseTask<T>: Task<T> {
    
    /// Test result
    let testResult: Result<T>
    
    
    /// Create new instance with specified result
    ///
    /// - Parameter result: Any `Result<T>`
    init(withResult result: Result<T>) {
        self.testResult = result
    }
    
    override func run() {
        finish(with: testResult)
    }
}

/// Returns a `Task<T>` instance that will finish with
/// specified result
///
/// - Parameter result: `Result<T>`
/// - Returns: `Task<T>` instance
internal func anyTask<T>(withResult result: Result<T>) -> Task<T> {
    return TestCaseTask(withResult: result)
}

/*
 Defines errors that can be used in test environment
 */
public enum TaskError: Error {
    
    /// Regular error with message
    case fail(String )
    
    /// Type erased combined errors
    case combined([Error])
}

// MARK: TestCase

/// Provides base interface for all Overdrive test case classes
class TestCase: XCTestCase {
    
    /// `DispatchQueue` instance used in test environment
    let dispatchQueue = DispatchQueue(label: String(describing: type(of: self)))
}
