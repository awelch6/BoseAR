//
//  Log+Subsystems.swift
//  HeadingExample
//
//  Created by Paul Calnan on 2/16/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import Foundation
import Logging

extension Log {

    /// The log subsystem for the HeadingExample app.
    private static let subsystem = "com.bose.ar.HeadingExample"

    /// Category for location-related logging. To enable location logging, set `Log.location.isEnabled = true` in the AppDelegate.
    static let location = Log(subsystem: subsystem, category: "location", isEnabled: false)
}
