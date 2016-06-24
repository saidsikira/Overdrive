//
//  CollectionType+Overdrive.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import class Foundation.NSOperation

extension CollectionType where Generator.Element: NSOperation {
    
    /**
     Cancel all tasks in collection.
    */
    public func cancel() {
        for operation in self {
            operation.cancel()
        }
    }
}
