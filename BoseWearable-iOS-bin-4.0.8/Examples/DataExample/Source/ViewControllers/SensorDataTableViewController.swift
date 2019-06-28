//
//  SensorDataTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 10/12/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class SensorDataTableViewController: UITableViewController {

    var device: WearableDevice!

    var sensorDispatch: SensorDispatch = SensorDispatch(queue: .main)

    private var token: ListenerToken?

    private var frequencyObservers: [SensorType: ObservedFrequencyUpdater] = [:]

    var changeSamplePeriodButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        sensorDispatch.handler = self

        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }

        updateChangeSamplePeriodButton()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            frequencyObservers.values.forEach {
                $0.stop()
            }
        }
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didUpdateSensorConfiguration, .didUpdateSensorInformation:
            configurationChangeComplete()
            tableView.reloadData()
            updateChangeSamplePeriodButton()

        case .didFailToWriteSensorConfiguration(let error):
            configurationChangeComplete()
            tableView.reloadData()
            show(error)

        default:
            break
        }
    }

    private func updateChangeSamplePeriodButton() {
        changeSamplePeriodButton?.isEnabled = (device.sensorConfiguration?.enabledSensors.count ?? 0) > 0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }

        return 1 + (device.sensorInformation?.availableSensors.count ?? 0)
    }

    private func cell(for sensor: SensorType, at indexPath: IndexPath) -> SensorDataCell {
        let id: String
        switch sensor {
        case .accelerometer, .gyroscope, .magnetometer, .orientation:
            id = "VectorSensorDataCell"
        case .gameRotation, .rotation:
            id = "QuaternionSensorDataCell"
        case .uncalibratedMagnetometer:
            id = "VectorBiasSensorDataCell"
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? SensorDataCell else {
            fatalError("Could not create cell")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return samplePeriodCell(at: indexPath)
        }
        else {
            return sensorCell(at: indexPath) ?? UITableViewCell()
        }
    }

    private func samplePeriodCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SamplePeriodCell", for: indexPath) as? SamplePeriodCell else {
            fatalError("Could not create cell")
        }

        changeSamplePeriodButton = cell.changeSamplePeriodButton
        updateChangeSamplePeriodButton()

        cell.setSamplePeriod(device.sensorConfiguration?.enabledSensorsSamplePeriod?.milliseconds ?? 0)
        cell.changeButtonTapped = { [weak self] in
            self?.changeSamplePeriod()
        }

        return cell
    }

    private func sensorCell(at indexPath: IndexPath) -> UITableViewCell? {
        guard let sensor = device.sensorInformation?.availableSensors[indexPath.row - 1] else {
            return nil
        }

        let cell = self.cell(for: sensor, at: indexPath)

        cell.configure(for: sensor)
        cell.setSensorEnabled(device.sensorConfiguration?.isEnabled(sensor: sensor) ?? false)

        cell.enabledSwitchChanged = { [weak self] enabled in
            self?.sensor(sensor, in: cell, changed: enabled)
        }

        if frequencyObservers[sensor] == nil {
            let updater = ObservedFrequencyUpdater(label: cell.observedFrequencyValue)
            frequencyObservers[sensor] = updater
            updater.start()
        }

        return cell
    }

    private func indexPath(for sensor: SensorType) -> IndexPath? {
        guard let sensorIndex = device.sensorInformation?.availableSensors.firstIndex(of: sensor) else {
            return nil
        }

        return IndexPath(row: sensorIndex + 1, section: 0)
    }

    private func sensor(_ sensor: SensorType, in cell: SensorDataCell, changed value: Bool) {
        if let samplePeriod = device.sensorConfiguration?.enabledSensorsSamplePeriod {
            if value {
                enable(sensor: sensor, at: samplePeriod)
            }
            else {
                disable(sensor: sensor)
            }
            return
        }

        SamplePeriodPrompt.showPrompt(device: device, from: self) { [weak self] result in
            switch result {
            case .success(let period):
                self?.enable(sensor: sensor, at: period)

            case .failure(let error):
                self?.show(error) {
                    cell.setSensorEnabled(!value)
                }

            case .cancelled:
                cell.setSensorEnabled(!value)
            }
        }
    }

    private func changeSamplePeriod() {
        SamplePeriodPrompt.showPrompt(device: device, from: self) { [weak self] result in
            switch result {
            case .success(let period):
                self?.changeSamplePeriod(to: period)

            case .failure(let error):
                self?.show(error)

            case .cancelled:
                return
            }
        }
    }

    private var activityIndicator: ActivityIndicator?

    private func changeSamplePeriod(to newPeriod: SamplePeriod) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureSensors { config in
            config.enabledSensorsSamplePeriod = newPeriod
        }
    }

    private func enable(sensor: SensorType, at samplePeriod: SamplePeriod) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureSensors { config in
            config.enable(sensor: sensor, at: samplePeriod)
        }
    }

    private func disable(sensor: SensorType) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureSensors { config in
            config.disable(sensor: sensor)
        }
    }

    private func configurationChangeComplete() {
        activityIndicator?.removeFromSuperview()
    }
}

extension SensorDataTableViewController: SensorDispatchHandler {

    // Use the sensor data event to update the frequency observers
    func receivedSensorData(_ data: SensorData) {
        for value in data.values {
            frequencyObservers[value.sensor]?.updateReceived()
        }
    }

    // We need to handle the individual sensors separately (instead of in one shot with the receivedSensorData function)
    // because we want any base reading adjustments to be applied to the data.

    func receivedAccelerometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        received(vector: vector, vectorAccuracy: accuracy, timestamp: timestamp, for: .accelerometer)
    }

    func receivedGyroscope(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        received(vector: vector, vectorAccuracy: accuracy, timestamp: timestamp, for: .gyroscope)
    }

    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        received(quaternion: quaternion, quaternionAccuracy: accuracy, timestamp: timestamp, for: .rotation)
    }

    func receivedGameRotation(quaternion: Quaternion, timestamp: SensorTimestamp) {
        received(quaternion: quaternion, timestamp: timestamp, for: .gameRotation)
    }

    func receivedOrientation(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        received(vector: vector, vectorAccuracy: accuracy, timestamp: timestamp, for: .orientation)
    }

    func receivedMagnetometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        received(vector: vector, vectorAccuracy: accuracy, timestamp: timestamp, for: .magnetometer)
    }

    func receivedUncalibratedMagnetometer(vector: Vector, bias: Vector, timestamp: SensorTimestamp) {
        received(vector: vector, bias: bias, timestamp: timestamp, for: .uncalibratedMagnetometer)
    }

    func received(vector: Vector? = nil,
                  vectorAccuracy: VectorAccuracy? = nil,
                  bias: Vector? = nil,
                  quaternion: Quaternion? = nil,
                  quaternionAccuracy: QuaternionAccuracy? = nil,
                  timestamp: SensorTimestamp,
                  for sensor: SensorType) {

        guard
            let indexPath = indexPath(for: sensor),
            let cell = tableView.cellForRow(at: indexPath) as? SensorDataCell
        else {
            return
        }

        if let v = vector {
            cell.update(vector: v)
        }

        if let a = vectorAccuracy {
            cell.update(vectorAccuracy: a)
        }

        if let b = bias {
            cell.update(bias: b)
        }

        if let q = quaternion {
            cell.update(quaternion: q)
        }

        if let a = quaternionAccuracy {
            cell.update(quaternionAccuracy: a)
        }

        cell.update(timestamp: timestamp)
    }
}
