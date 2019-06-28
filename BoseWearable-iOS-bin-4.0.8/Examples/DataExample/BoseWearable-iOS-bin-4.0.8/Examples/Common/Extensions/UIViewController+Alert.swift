//
//  UIViewController+Alert.swift
//  Common
//
//  Created by Paul Calnan on 9/19/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import UIKit

/// Alert dialog utilities
extension UIViewController {

    /**
     Show an alert for the specified error. If the error is non-nil, its localized description will be shown as the message. Otherwise, a generic error message is shown.

     - parameter error: The error to be displayed.
     - parameter dismissHandler: The callback to be invoked when the alert's action is performed.
     */
    public func show(_ error: Error?, dismissHandler: (() -> Void)? = nil) {
        let message: String?
        if let localized = error as? LocalizedError? {
            message = localized?.errorDescription
        }
        else {
            message = error?.localizedDescription
        }

        showAlert(title: "Error", message: message ?? "An unknown error occurred", dismissHandler: dismissHandler)
    }

    /**
     Show an alert with the specified title and message.

     - parameter title: The title of the alert.
     - parameter message: The alert message.
     - parameter dismissHandler: The callback to be invoked when the alert's action is performed.
     */
    public func showAlert(title: String, message: String? = nil, dismissHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            dismissHandler?()
        }))

        present(alert, animated: true)
    }
}
