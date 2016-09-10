//
//  NSQualityOfService+Overdrive.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import enum Foundation.NSQualityOfService

extension QualityOfService: CustomStringConvertible {
    
    /// Returns textual representation of `self`
    public var description: String {
        switch self {
        case .default:
            return "Default"
        case .userInitiated:
            return "UserInitiated"
        case .utility:
            return "Utility"
        case .userInteractive:
            return "UserInteractive"
        case .background:
            return "Background"
        }
    }
}
