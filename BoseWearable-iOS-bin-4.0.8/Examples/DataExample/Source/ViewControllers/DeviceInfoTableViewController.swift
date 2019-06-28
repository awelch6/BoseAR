//
//  DeviceInfoTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 8/16/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BLECore
import BoseWearable
import UIKit

class DeviceInfoTableViewController: UITableViewController {

    var device: WearableDevice!

    @IBOutlet var systemID: UILabel!
    @IBOutlet var modelNumber: UILabel!
    @IBOutlet var serialNumber: UILabel!
    @IBOutlet var firmwareRevision: UILabel!
    @IBOutlet var hardwareRevision: UILabel!
    @IBOutlet var softwareRevision: UILabel!
    @IBOutlet var manufacturerName: UILabel!
    @IBOutlet var regulatoryCertificationData: UILabel!
    @IBOutlet var pnpID: UILabel!

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
        device.refreshDeviceInformation()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateDeviceInformation = event else {
            return
        }
        refreshControl?.endRefreshing()
        reload()
    }

    private func reload() {
        let info = device.deviceInformation

        systemID.text = format(data: info?.systemID)
        modelNumber.text = info?.modelNumber
        serialNumber.text = info?.serialNumber
        firmwareRevision.text = info?.firmwareRevision
        hardwareRevision.text = info?.hardwareRevision
        softwareRevision.text = info?.softwareRevision
        manufacturerName.text = info?.manufacturerName
        regulatoryCertificationData.text = format(data: info?.regulatoryCertificationDataList)
        pnpID.text = format(data: info?.pnpID)
    }
}
