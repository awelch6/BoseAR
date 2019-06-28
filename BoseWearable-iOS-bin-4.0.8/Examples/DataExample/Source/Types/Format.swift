//
//  Format.swift
//  DataExample
//
//  Created by Paul Calnan on 10/12/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import Foundation

/// Utility functions for formatting numeric values.
struct Format {

    /// Formats the specified decimal value as a string.
    static func decimal(_ value: Double) -> String {
        return String(format: "%0.03f", value)
    }

    /// Formats the specified degree value as a string.
    static func degrees(_ value: Double) -> String {
        return String(format: "%0.02f°", value)
    }

    /// Converts the specified radian value to degrees then formats that as a string.
    static func degrees(radians: Double) -> String {
        return degrees(radians * 180 / Double.pi)
    }

    /// Converts the specified quaternion accuracy value to degrees then formats that as a string.
    static func accuracy(_ acc: QuaternionAccuracy) -> String {
        return degrees(radians: acc.estimatedAccuracy)
    }
}
