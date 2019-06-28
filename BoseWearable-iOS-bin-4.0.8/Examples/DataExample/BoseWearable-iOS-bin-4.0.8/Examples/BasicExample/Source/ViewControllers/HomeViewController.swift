//
//  HomeTableViewController.swift
//  BasicExample
//
//  Created by Paul Calnan on 11/26/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class HomeViewController: UITableViewController {

    private var activityIndicator: ActivityIndicator?

    @IBOutlet var connectToLast: UISwitch!

    @IBOutlet var versionLabel: UILabel!

    /// Determine the search mode based on the state of the autoselect switch
    private var mode: ConnectUIMode {
        return connectToLast.isOn

            // This option only shows the connect UI if the most-recently
            // connected device is not found within 5 seconds. If the most-
            // recently connected device is found before 5 seconds has elapsed,
            // it is automatically selected.
            ? .connectToLast(timeout: 5)

            // This option will always immediately show the connect UI.
            : .alwaysShow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "BoseWearable \(BoseWearable.formattedVersion)"
    }

    @IBAction func connectTapped(_ sender: Any) {
        // Block this view controller's UI before showing the modal search.
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)

        let sensorIntent = SensorIntent(sensors: [.rotation, .accelerometer], samplePeriods: [._20ms])

        // Perform the device search and connect to the selected device. This
        // may present a view controller on a new UIWindow.
        BoseWearable.shared.startConnection(mode: mode, sensorIntent: sensorIntent) { result in
            switch result {
            case .success(let session):
                // A device was selected, a session was created and opened. Show
                // a view controller that will become the session delegate.
                self.showDeviceInfo(for: session)

            case .failure(let error):
                // An error occurred when searching for or connecting to a
                // device. Present an alert showing the error.
                self.show(error)

            case .cancelled:
                // The user cancelled the search operation.
                break
            }

            // Unblock the UI
            self.activityIndicator?.removeFromSuperview()
        }
    }

    @IBAction func useSimulatedDeviceTapped(_ sender: Any) {
        // Create a session for a simulated device.
        showDeviceInfo(for: BoseWearable.shared.createSimulatedWearableDeviceSession())
    }

    private func showDeviceInfo(for session: WearableDeviceSession) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DeviceTableViewController") as? DeviceTableViewController else {
            fatalError("Cannot instantiate view controller")
        }

        vc.session = session
        show(vc, sender: self)
    }
}
