//
//  Create.swift
//  Overdrive
//
//  Created by Said Sikira on 6/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

extension Task {
    
    // MARK: Inline task creation
    
    
    /// Create inline task with completion block
    ///
    /// **Example:**
    ///
    /// ```swift
    /// let inlineTask = Task.create {
    ///    doWork()
    /// }
    /// ```
    ///
    /// - parameter taskBlock: Block in which task is executed.
    ///
    /// - returns: InlineTask instance
    public class func create(_ taskBlock: @escaping ((Void) -> Void)) -> InlineTask {
        return InlineTask {
            taskBlock()
        }
    }
}
