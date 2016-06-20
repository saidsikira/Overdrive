//
//  TaskQueueDelegate.swift
//  Overdrive
//
//  Created by Said Sikira on 6/20/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

public protocol TaskQueueDelegate: class {
    func didAdd<T>(task task: Task<T>, toQueue queue: TaskQueue)
    func didFinish<T>(task task: Task<T>, inQueue queue: TaskQueue)
    func didCancel<T>(task task: Task<T>, inQueue queue: TaskQueue)
}