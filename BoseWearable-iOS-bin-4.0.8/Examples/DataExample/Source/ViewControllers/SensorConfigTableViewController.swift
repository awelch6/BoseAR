//
//  SensorConfigTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 10/3/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class SensorConfigTableViewController: UITableViewController {

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
        switch event {
        case .didUpdateSensorConfiguration:
            refreshControl?.endRefreshing()
            configurationChangeComplete()
            reload()

        case .didFailToWriteSensorConfiguration(let error):
            configurationChangeComplete()
            show(error)

        default:
            break
        }
    }

    @IBAction func refresh(_ sender: Any) {
        device.refreshSensorConfiguration()
    }

    private func reload() {
        tableView.reloadData()

        if hasData {
            tableView.backgroundView = nil
        }
        else {
            let label = UILabel(frame: CGRect.zero)
            label.text = "Sensor Config Unavailable"
            label.sizeToFit()

            label.font = UIFont.systemFont(ofSize: 21)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray

            tableView.backgroundView = label
        }
    }

    // MARK: - Table view data source

    private var hasData: Bool {
        return device?.sensorConfiguration?.allSensors.count ?? 0 > 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasData ? 2 : 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard hasData, section == 0 else {
            return nil
        }
        return "Sensors"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard hasData, section == 0 else {
            return nil
        }
        return "Select a sensor to change sample period. Note that all enabled sensors will be updated to have the same sample period."
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return device?.sensorConfiguration?.allSensors.count ?? 0
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sensorCell", for: indexPath)

            if let config = device?.sensorConfiguration {
                let sensor = config.allSensors[indexPath.row]
                let period = config.samplePeriod(for: sensor)?.description ?? "0 ms"

                cell.textLabel?.text = sensor.description
                cell.detailTextLabel?.text = "\(period)"
            }

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "disableCell", for: indexPath)

            cell.textLabel?.text = "Disable all sensors"

            return cell

        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            guard let sensor = device?.sensorConfiguration?.allSensors[indexPath.row] else {
                return
            }
            promptForSamplePeriod(sensor: sensor)

        case 1:
            self.disableAll()

        default:
            break
        }
    }

    private func promptForSamplePeriod(sensor: SensorType) {
        guard let info = device.sensorInformation else {
            showAlert(title: "Error", message: "Sensor information not available")
            return
        }

        let prompt = UIAlertController(title: sensor.description, message: "Select the sample period", preferredStyle: .alert)

        for period in info.availableSamplePeriods(for: sensor).sorted(by: { $0.milliseconds > $1.milliseconds }) {
            prompt.addAction(UIAlertAction(title: period.description, style: .default, handler: { [unowned self] _ in
                self.enable(sensor: sensor, at: period)
            }))
        }
        prompt.addAction(UIAlertAction(title: "Disable sensor", style: .destructive, handler: { [unowned self] _ in
            self.disable(sensor: sensor)
        }))
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(prompt, animated: true)
    }

    private var activityIndicator: ActivityIndicator?

    private func disable(sensor: SensorType) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureSensors { config in
            config.disable(sensor: sensor)
        }
    }

    private func disableAll() {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureSensors { config in
            config.disableAll()
        }
    }

    private func enable(sensor: SensorType, at samplePeriod: SamplePeriod) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureSensors { config in
            config.enable(sensor: sensor, at: samplePeriod)
        }
    }

    private func configurationChangeComplete() {
        activityIndicator?.removeFromSuperview()
    }
}
