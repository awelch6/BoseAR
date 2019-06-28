//
//  SensorInfoListTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 9/27/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class SensorInfoListTableViewController: UITableViewController {

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
        reload()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateSensorInformation = event else {
            return
        }

        refreshControl?.endRefreshing()
        reload()
    }

    @IBAction func refresh(_ sender: Any) {
        device.refreshSensorInformation()
    }

    private var hasData: Bool {
        return (device.sensorInformation?.availableSensors.count ?? 0) > 0
    }

    private func reload() {
        tableView.reloadData()

        if hasData {
            tableView.backgroundView = nil
        }
        else {
            let label = UILabel(frame: CGRect.zero)
            label.text = "Sensor Info Unavailable"
            label.sizeToFit()

            label.font = UIFont.systemFont(ofSize: 21)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray

            tableView.backgroundView = label
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasData ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return device.sensorInformation?.availableSensors.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sensorCell", for: indexPath)

        let sensor = device.sensorInformation?.availableSensors[indexPath.row]
        cell.textLabel?.text = sensor?.description

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SensorInfoEntryTableViewController") as? SensorInfoEntryTableViewController else {
            return
        }

        let sensor = device.sensorInformation?.availableSensors[indexPath.row]
        vc.device = device
        vc.sensor = sensor

        show(vc, sender: self)
    }
}
