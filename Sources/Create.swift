//
//  Create.swift
//  Overdrive
//
//  Created by Said Sikira on 6/26/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

extension Task {
    
    //MARK: Task creation
    
    /**
     Create inline task with completion block
     
     **Example:**
     
     ```swift
     let inlineTask = Task.create {
        doWork()
     }
     ```
     
     - Parameter taskBlock: Block in which task is executed.
     
     - Returns: InlineTask instance
    */
    public class func create(_ taskBlock: @escaping ((Void) -> Void)) -> InlineTask {
        return InlineTask {
            taskBlock()
        }
    }
}
