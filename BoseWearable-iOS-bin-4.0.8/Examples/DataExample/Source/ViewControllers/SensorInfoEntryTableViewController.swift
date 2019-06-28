//
//  SensorInfoEntryTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 9/27/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class SensorInfoEntryTableViewController: UITableViewController {

    var device: WearableDevice!

    var sensor: SensorType!

    private var token: ListenerToken?

    @IBOutlet var sensorTypeLabel: UILabel!
    @IBOutlet var scaledValueRangeLabel: UILabel!
    @IBOutlet var rawValueRangeLabel: UILabel!
    @IBOutlet var _320msCell: UITableViewCell!
    @IBOutlet var _160msCell: UITableViewCell!
    @IBOutlet var _80msCell: UITableViewCell!
    @IBOutlet var _40msCell: UITableViewCell!
    @IBOutlet var _20msCell: UITableViewCell!
    @IBOutlet var _10msCell: UITableViewCell!
    @IBOutlet var _5msCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = sensor.description
        reload()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateSensorInformation = event else {
            return
        }

        reload()
    }

    private func reload() {
        sensorTypeLabel.text = sensor.description
        scaledValueRangeLabel.text = format(device.sensorInformation?.scaledValueRange(for: sensor))
        rawValueRangeLabel.text = format(device.sensorInformation?.rawValueRange(for: sensor))

        configure(_320msCell, for: ._320ms)
        configure(_160msCell, for: ._160ms)
        configure(_80msCell, for: ._80ms)
        configure(_40msCell, for: ._40ms)
        configure(_20msCell, for: ._20ms)
        configure(_10msCell, for: ._10ms)
        configure(_5msCell, for: ._5ms)
    }

    private func format(_ range: Range<Int16>?) -> String? {
        guard let range = range else {
            return nil
        }
        return "\(range.lowerBound) .. \(range.upperBound)"
    }

    private func configure(_ cell: UITableViewCell, for period: SamplePeriod) {
        cell.accessoryType =
            device.sensorInformation?.availableSamplePeriods(for: sensor).contains(period) ?? false
            ? .checkmark
            : .none
    }
}
