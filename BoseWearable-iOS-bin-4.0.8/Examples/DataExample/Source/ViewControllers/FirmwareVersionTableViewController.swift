//
//  FirmwareVersionTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 4/23/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class FirmwareVersionTableViewController: UITableViewController {

    var device: WearableDevice!

    @IBOutlet var firmwareVersionLabel: UILabel!

    @IBOutlet var updateStatusLabel: UILabel!

    @IBOutlet var updateUrlLabel: UILabel!

    @IBOutlet var openUpdateButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let fwVersion = device.firmwareVersion

        firmwareVersionLabel.text = fwVersion?.version ?? "(nil)"

        switch fwVersion?.updateStatus {
        case .none:
            updateStatusLabel.text = "(nil)"
            openUpdateButton.isEnabled = false

        case .some(.upToDate):
            updateStatusLabel.text = "Up to date"
            openUpdateButton.isEnabled = false

        case .some(.updateAvailable(let version)):
            updateStatusLabel.text = "Update to \(version) available"
            openUpdateButton.isEnabled = true
        }

        updateUrlLabel.text = fwVersion?.firmwareUpdateApp?.url.description ?? "(nil)"
    }

    @IBAction func openUpdateButtonTapped(_ sender: Any) {
        guard let url = device.firmwareVersion?.firmwareUpdateApp?.url else {
            return
        }

        UIApplication.shared.open(url)
    }
}
