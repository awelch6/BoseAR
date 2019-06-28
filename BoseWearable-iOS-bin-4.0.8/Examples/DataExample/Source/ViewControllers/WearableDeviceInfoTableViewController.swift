//
//  WearableDeviceInfoTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 9/26/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class WearableDeviceInfoTableViewController: UITableViewController {

    var device: WearableDevice!

    @IBOutlet var majorVersion: UILabel!
    @IBOutlet var minorVersion: UILabel!
    @IBOutlet var productID: UILabel!
    @IBOutlet var variant: UILabel!
    @IBOutlet var transmissionPeriod: UILabel!
    @IBOutlet var maxPayloadPerTransmissionPeriod: UILabel!
    @IBOutlet var maxActiveSensors: UILabel!

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

    @IBAction func refresh(_ sender: Any) {
        device.refreshWearableDeviceInformation()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateWearableDeviceInformation = event else {
            return
        }
        refreshControl?.endRefreshing()
        reload()
    }

    private func reload() {
        let info = device.wearableDeviceInformation

        majorVersion.text = info?.majorVersion.description
        minorVersion.text = info?.minorVersion.description
        productID.text = info?.productID.description
        variant.text = info?.variant.description
        transmissionPeriod.text = info?.transmissionPeriod.description
        maxPayloadPerTransmissionPeriod.text = info?.maximumPayloadPerTransmissionPeriod.description
        maxActiveSensors.text = info?.maximumActiveSensors.description
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }

        switch segue.identifier ?? "" {
        case "showDeviceStatus":
            guard let vc = segue.destination as? DeviceStatusTableViewController else {
                return
            }
            vc.device = device

        case "showAvailableSensors":
            guard let vc = segue.destination as? AvailableSensorsTableViewController else {
                return
            }
            vc.device = device

        case "showAvailableGestures":
            guard let vc = segue.destination as? AvailableGesturesTableViewController else {
                return
            }
            vc.device = device

        default:
            return
        }
    }
}
