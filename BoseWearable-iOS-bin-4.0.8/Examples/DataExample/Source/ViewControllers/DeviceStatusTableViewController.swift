//
//  DeviceStatusTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 2/12/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class DeviceStatusTableViewController: UITableViewController {

    var device: WearableDevice!

    var token: ListenerToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    @IBAction func refresh(_ sender: Any) {
        device.refreshWearableDeviceInformation()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateWearableDeviceInformation = event else {
            return
        }
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configure(cell, forRow: indexPath.row)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else {
            return nil
        }

        return "Each cell corresponds to a bit in the device status bit field. A checkmark appears on the right of the cell if that bit is set."
    }

    /// Convenience accessor to get current device status
    var deviceStatus: DeviceStatus? {
        return device.wearableDeviceInformation?.deviceStatus
    }

    func configure(_ cell: UITableViewCell, forRow row: Int) {
        switch row {
        case 0:
            cell.textLabel?.text = "Pairing enabled"
            cell.accessoryType = deviceStatus?.contains(.pairingEnabled) ?? false ? .checkmark : .none

        case 1:
            cell.textLabel?.text = "Secure BLE pairing required"
            cell.accessoryType = deviceStatus?.contains(.secureBLEPairingRequired) ?? false ? .checkmark : .none

        case 2:
            cell.textLabel?.text = "Already paired to client"
            cell.accessoryType = deviceStatus?.contains(.alreadyPairedToClient) ?? false ? .checkmark : .none

        case 3:
            cell.textLabel?.text = "Wearable sensors service suspended"
            cell.accessoryType = deviceStatus?.contains(.wearableSensorsServiceSuspended) ?? false ? .checkmark : .none

        case 4:
            cell.textLabel?.text = "Reason: \(deviceStatus?.suspensionReason.description ?? "(nil)")"
            cell.accessoryType = .none

        default:
            cell.textLabel?.text = nil
            cell.accessoryType = .none
        }
    }
}
