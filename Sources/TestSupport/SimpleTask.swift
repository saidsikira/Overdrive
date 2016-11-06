//
//  SimpleTask.swift
//  Overdrive
//
//  Created by Said Sikira on 8/28/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Overdrive

/**
 `Task<Int>` subclass that always finishes with `Int` value
*/
public class SimpleTask: Task<Int> {
    override public func run() {
        finish(with: .value(10))
    }
}

