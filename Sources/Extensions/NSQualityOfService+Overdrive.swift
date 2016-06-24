//
//  NSQualityOfService+Overdrive.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import enum Foundation.NSQualityOfService

extension NSQualityOfService: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Default:
            return "Default"
        case .UserInitiated:
            return "UserInitiated"
        case .Utility:
            return "Utility"
        case .UserInteractive:
            return "UserInteractive"
        case .Background:
            return "Background"
        }
    }
}
