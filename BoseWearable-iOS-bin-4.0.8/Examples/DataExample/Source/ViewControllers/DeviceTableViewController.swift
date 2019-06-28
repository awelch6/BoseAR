//
//  DeviceTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 8/16/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import simd
import UIKit

class DeviceTableViewController: UITableViewController {

    // The session is set by the HomeViewController before this view controller is shown.
    // When this view controller is popped and deallocated, the session will be released and deallocated. This will cause the connection to be closed.
    var session: WearableDeviceSession! {
        didSet {
            session?.delegate = self
        }
    }

    var device: WearableDevice? {
        return session.device
    }

    private var suspensionOverlay: SuspensionOverlay?

    private var token: ListenerToken?

    // Keep the gesture data model here so it accumulates gestures even when the gesture data view controller is not on screen
    private let gestureDataModel = GestureDataModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateTitle()

        // If we are not already in the navigation stack...
        if isMovingToParent {
            token = session.device?.addEventListener(queue: .main) { [weak self] event in
                self?.wearableDeviceEvent(event)
            }
        }
    }

    private func updateTitle() {
        title = device?.name ?? "Device"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }

        switch segue.identifier {
        case "showDeviceInfo":
            guard let vc = segue.destination as? DeviceInfoTableViewController else {
                return
            }
            vc.device = device

        case "showWearableDeviceInfo":
            guard let vc = segue.destination as? WearableDeviceInfoTableViewController else {
                return
            }
            vc.device = device

        case "showFirmwareVersion":
            guard let vc = segue.destination as? FirmwareVersionTableViewController else {
                return
            }
            vc.device = device

        case "showSettings":
            guard let vc = segue.destination as? SettingsTableViewController else {
                return
            }
            vc.device = device

        case "showSensorInfoList":
            guard let vc = segue.destination as? SensorInfoListTableViewController else {
                return
            }
            vc.device = device

        case "showSensorConfig":
            guard let vc = segue.destination as? SensorConfigTableViewController else {
                return
            }
            vc.device = device

        case "showSensorData":
            guard let vc = segue.destination as? SensorDataTableViewController else {
                return
            }
            vc.device = device

        case "showGestureInfo":
            guard let vc = segue.destination as? GestureInfoTableViewController else {
                return
            }
            vc.device = device

        case "showGestureConfig":
            guard let vc = segue.destination as? GestureConfigTableViewController else {
                return
            }
            vc.device = device

        case "showGestureData":
            guard let vc = segue.destination as? GestureDataTableViewController else {
                return
            }
            vc.dataModel = gestureDataModel

        default:
            return
        }
    }
}

extension DeviceTableViewController: WearableDeviceSessionDelegate {

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didSuspendWearableSensorService(let reason):
            // Block the UI when the sensor service is suspended.
            suspensionOverlay = SuspensionOverlay.add(to: navigationController?.view, reason: reason)

        case .didResumeWearableSensorService:
            // Unblock the UI when the sensor service is resumed.
            suspensionOverlay?.removeFromSuperview()

        default:
            break
        }
    }

    func sessionDidOpen(_ session: WearableDeviceSession) { }

    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) { }

    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        suspensionOverlay?.removeFromSuperview()

        guard let error = error else {
            returnToHomeScreen()
            return
        }

        show(error) { [weak self] in
            self?.returnToHomeScreen()
        }
    }

    private func returnToHomeScreen() {
        // Remove any activity indicators. This handles an edge case where a firmware crash (or other remote disconnection) occurs while a blocking update (one that shows an activity indicator) is in progress.
        // Note that any view below us in the navigation stack may add an activity indicator, not just us. Thus we have to iterate over subviews of the navigation controller to remove any activity indicators.
        navigationController?.view.subviews.forEach {
            if $0 is ActivityIndicator {
                $0.removeFromSuperview()
            }
        }

        // Remove any suspension overlay. This would only come from this view controller, so we don't need to iterate over the view hierarchy like we did above.
        suspensionOverlay?.removeFromSuperview()

        navigationController?.popToRootViewController(animated: true)
    }
}
