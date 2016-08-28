//
//  FailableTask.swift
//  Overdrive
//
//  Created by Said Sikira on 8/28/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Overdrive

/**
 `Task<Int>` subclass that always finishes with Error
 */
class FailableTask: Task<Int> {
    override func run() {
        finish(.Error(TaskError.Fail("Failed")))
    }
}
