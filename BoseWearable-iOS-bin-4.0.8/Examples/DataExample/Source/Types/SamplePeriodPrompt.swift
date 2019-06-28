//
//  SamplePeriodPrompt.swift
//  DataExample
//
//  Created by Paul Calnan on 10/12/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

/// Prompts the user to select a sample period.
struct SamplePeriodPrompt {

    /**
     Prompt the user to select a sample period.

     - parameter device: The device being configured. The available sample periods are pulled from here.
     - parameter viewController: Present the prompt modally on this view controller.
     - parameter completionHandler: Callback to invoke with the result of the operation.
     */
    static func showPrompt(device: WearableDevice, from viewController: UIViewController, completionHandler: @escaping (CancellableResult<SamplePeriod>) -> Void) {
        let title = "Sample Period"
        let message = "Select the sample period for all enabled sensors"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        device.sensorInformation?.availableSamplePeriods.forEach { period in
            alert.addAction(UIAlertAction(title: period.description, style: .default, handler: { _ in
                completionHandler(.success(period))
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completionHandler(.cancelled)
        }))

        viewController.present(alert, animated: true)
    }
}
