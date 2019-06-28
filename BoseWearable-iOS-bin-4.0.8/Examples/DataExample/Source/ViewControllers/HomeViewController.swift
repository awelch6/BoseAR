//
//  HomeViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 9/19/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class HomeViewController: UITableViewController {

    private var activityIndicator: ActivityIndicator?

    @IBOutlet var connectToLast: UISwitch!

    @IBOutlet var versionLabel: UILabel!

    private var mode: ConnectUIMode {
        return connectToLast.isOn
            ? .connectToLast(timeout: 5)
            : .alwaysShow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "BoseWearable \(BoseWearable.formattedVersion)"
    }

    @IBAction func connectTapped(_ sender: Any) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)

        BoseWearable.shared.startConnection(mode: mode) { result in
            switch result {
            case .success(let session):
                self.showDeviceInfo(for: session)

            case .failure(let error):
                self.show(error)

            case .cancelled:
                break
            }

            self.activityIndicator?.removeFromSuperview()
        }
    }

    @IBAction func useSimulatedDeviceTapped(_ sender: Any) {
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
