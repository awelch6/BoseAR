//
//  AvailableSensorsTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 9/26/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class AvailableSensorsTableViewController: UITableViewController {

    var device: WearableDevice!

    private var token: ListenerToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateWearableDeviceInformation = event else {
            return
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SensorType.all.count
    }

    private func isAvailable(_ sensor: SensorType) -> Bool {
        return device.wearableDeviceInformation?.availableSensors.contains(sensor) ?? false
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sensor = SensorType.all[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = sensor.description
        cell.accessoryType = isAvailable(sensor) ? .checkmark : .none

        return cell
    }
}
