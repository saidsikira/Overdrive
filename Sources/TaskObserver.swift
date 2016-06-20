//
//  TaskObserver.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

public protocol TaskObserver {
    func taskDidStartExecution<T>(task: Task<T>)
    func taskDidFinishExecution<T>(task: Task<T>)
}
