//
//  UIViewController+Format.swift
//  Common
//
//  Created by Paul Calnan on 8/13/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import UIKit

/// String formatting utilities
extension UIViewController {

    /// Utility to format radians as degrees with two decimal places and a degree symbol.
    func format(radians: Double) -> String {
        let degrees = radians * 180 / Double.pi
        return String(format: "%.02f°", degrees)
    }

    /// Utility to format radians as degrees with two decimal places and a degree symbol.
    func format(radians: Float) -> String {
        let degrees = radians * 180 / Float.pi
        return String(format: "%.02f°", degrees)
    }

    /// Utility to format degrees with two decimal places and a degree symbol.
    func format(degrees: Double) -> String {
        return String(format: "%.02f°", degrees)
    }

    /// Utility to format a double with four decimal places.
    func format(decimal: Double) -> String {
        return String(format: "%.04f", decimal)
    }

    /// Converts the byte sequence of this Data object into a hexadecimal representation (two lowercase characters per byte).
    func format(data: Data?) -> String? {
        return data?.map({ String(format: "%02hhX", $0) }).joined()
    }
}
