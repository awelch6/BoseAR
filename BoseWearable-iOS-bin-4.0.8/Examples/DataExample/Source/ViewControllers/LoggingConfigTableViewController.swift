//
//  LoggingConfigTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 11/26/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BLECore
import BoseWearable
import UIKit

class LoggingConfigTableViewController: UITableViewController {

    @IBOutlet var boseWearableConnectUI: UISwitch!
    @IBOutlet var boseWearableDevice: UISwitch!
    @IBOutlet var boseWearableSensor: UISwitch!
    @IBOutlet var boseWearableSensorData: UISwitch!
    @IBOutlet var boseWearableService: UISwitch!
    @IBOutlet var boseWearableSession: UISwitch!

    @IBOutlet var bleCoreDevice: UISwitch!
    @IBOutlet var bleCoreDiscovery: UISwitch!
    @IBOutlet var bleCoreService: UISwitch!
    @IBOutlet var bleCoreSession: UISwitch!
    @IBOutlet var bleCoreTraffic: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    @IBAction func switchChanged(_ sender: Any) {
        updateConfig()
    }

    private func updateUI() {
        boseWearableConnectUI.isOn = BoseWearable.isConnectUILoggingEnabled
        boseWearableDevice.isOn = BoseWearable.isDeviceLoggingEnabled
        boseWearableSensor.isOn = BoseWearable.isSensorLoggingEnabled
        boseWearableSensorData.isOn = BoseWearable.isSensorDataLoggingEnabled
        boseWearableService.isOn = BoseWearable.isServiceLoggingEnabled
        boseWearableSession.isOn = BoseWearable.isSessionLoggingEnabled

        bleCoreDevice.isOn = BLECore.isDeviceLoggingEnabled
        bleCoreDiscovery.isOn = BLECore.isDiscoveryLoggingEnabled
        bleCoreService.isOn = BLECore.isServiceLoggingEnabled
        bleCoreSession.isOn = BLECore.isSessionLoggingEnabled
        bleCoreTraffic.isOn = BLECore.isTrafficLoggingEnabled
    }

    private func updateConfig() {
        BoseWearable.isConnectUILoggingEnabled = boseWearableConnectUI.isOn
        BoseWearable.isDeviceLoggingEnabled = boseWearableDevice.isOn
        BoseWearable.isSensorLoggingEnabled = boseWearableSensor.isOn
        BoseWearable.isSensorDataLoggingEnabled = boseWearableSensorData.isOn
        BoseWearable.isServiceLoggingEnabled = boseWearableService.isOn
        BoseWearable.isSessionLoggingEnabled = boseWearableSession.isOn

        BLECore.isDeviceLoggingEnabled = bleCoreDevice.isOn
        BLECore.isDiscoveryLoggingEnabled = bleCoreDiscovery.isOn
        BLECore.isServiceLoggingEnabled = bleCoreService.isOn
        BLECore.isSessionLoggingEnabled = bleCoreSession.isOn
        BLECore.isTrafficLoggingEnabled = bleCoreTraffic.isOn
    }

    @IBAction func enableAll(_ sender: Any) {
        BLECore.enableAllLogging()
        BoseWearable.enableAllLogging()
        updateUI()
    }

    @IBAction func enableCommon(_ sender: Any) {
        BLECore.enableCommonLogging()
        BoseWearable.enableCommonLogging()
        updateUI()
    }

    @IBAction func disableAll(_ sender: Any) {
        BLECore.disableAllLogging()
        BoseWearable.disableAllLogging()
        updateUI()
    }
}
