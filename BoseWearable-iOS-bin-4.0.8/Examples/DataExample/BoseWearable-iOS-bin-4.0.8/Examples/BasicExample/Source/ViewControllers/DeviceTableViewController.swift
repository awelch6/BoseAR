//
//  DeviceTableViewController.swift
//  BasicExample
//
//  Created by Paul Calnan on 11/19/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import simd
import UIKit

class DeviceTableViewController: UITableViewController {

    /// Set by the showing/presenting code.
    var session: WearableDeviceSession! {
        didSet {
            session?.delegate = self
        }
    }

    /// Used to block the UI when sensor service is suspended.
    private var suspensionOverlay: SuspensionOverlay?

    // We create the SensorDispatch without any reference to a session or a device.
    // We provide a queue on which the sensor data events are dispatched on.
    private let sensorDispatch = SensorDispatch(queue: .main)

    /// Retained for the lifetime of this object. When deallocated, deregisters
    /// this object as a WearableDeviceEvent listener.
    private var token: ListenerToken?

    // MARK: - IBOutlets

    @IBOutlet var pitchValue: UILabel!
    @IBOutlet var rollValue: UILabel!
    @IBOutlet var yawValue: UILabel!

    @IBOutlet var xValue: UILabel!
    @IBOutlet var yValue: UILabel!
    @IBOutlet var zValue: UILabel!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // We set this object as the sensor dispatch handler in order to receive
        // sensor data.
        sensorDispatch.handler = self

        // Update the label font to use monospaced numbers.
        [pitchValue, rollValue, yawValue, xValue, yValue, zValue].forEach {
            $0?.useMonospacedNumbers()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If we are being pushed on to a navigation controller...
        if isMovingToParent {
            // ... this view controller is being shown for the first time

            // Set the title to the device's name.
            title = session.device?.name

            // Listen for wearable device events.
            listenForWearableDeviceEvents()

            // Listen for sensor data.
            listenForSensors()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // If we are being popped from a navigation controller...
        if isMovingFromParent {
            // Disable all sensors when dismissing. Since we retain the session
            // and will be deallocated after this, the session will be deallocated
            // and the communications channel closed.
            stopListeningForSensors()
        }
    }

    // Error handler function called at various points in this class.  If an error
    // occurred, show it in an alert. When the alert is dismissed, this function
    // dismisses this view controller by popping to the root view controller (we are
    // assumed to be on a navigation stack).
    private func dismiss(dueTo error: Error?, isClosing: Bool = false) {
        // Common dismiss handler passed to show()/showAlert().
        let popToRoot = { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }

        // If the connection did close and it was not due to an error, just show
        // an appropriate message.
        if isClosing && error == nil {
            navigationController?.showAlert(title: "Disconnected", message: "The connection was closed", dismissHandler: popToRoot)
        }
        // Show an error alert.
        else {
            navigationController?.show(error, dismissHandler: popToRoot)
        }
    }

    private func listenForWearableDeviceEvents() {
        // Listen for incoming wearable device events. Retain the ListenerToken.
        // When the ListenerToken is deallocated, this object is automatically
        // removed as an event listener.
        token = session.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didFailToWriteSensorConfiguration(let error):
            // Show an error if we were unable to set the sensor configuration.
            show(error)

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

    private func listenForSensors() {
        // Configure sensors at 50 Hz (a 20 ms sample period)
        session.device?.configureSensors { config in

            // Here, config is the current sensor config. We begin by turning off
            // all sensors, allowing us to start with a "clean slate."
            config.disableAll()

            // Enable the rotation and accelerometer sensors
            config.enable(sensor: .rotation, at: ._20ms)
            config.enable(sensor: .accelerometer, at: ._20ms)
        }
    }

    private func stopListeningForSensors() {
        // Disable all sensors.
        session.device?.configureSensors { config in
            config.disableAll()
        }
    }
}

// MARK: - SensorDispatchHandler

// Note, we only have to implement the SensorDispatchHandler functions for the
// sensors we are interested in. These functions are called on the main queue
// as that is the queue provided to the SensorDispatch initializer.

extension DeviceTableViewController: SensorDispatchHandler {

    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap

        let pitch = qResult.xRotation
        let roll = qResult.yRotation
        let yaw = -qResult.zRotation

        pitchValue.text = format(radians: pitch)
        rollValue.text = format(radians: roll)
        yawValue.text = format(radians: yaw)
    }

    func receivedAccelerometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        xValue.text = format(decimal: vector.x)
        yValue.text = format(decimal: vector.y)
        zValue.text = format(decimal: vector.z)
    }
}

// MARK: - WearableDeviceSessionDelegate

extension DeviceTableViewController: WearableDeviceSessionDelegate {
    func sessionDidOpen(_ session: WearableDeviceSession) {
        // This view controller is only shown after the session has successfully
        // opened. It is dismissed when the session closes. We don't need to do
        // anything here.
    }

    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {
        // This view controller is only shown after the session has successfully
        // opened. It is dismissed when the session closes. We don't need to do
        // anything here.
    }

    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        // The session was closed, possibly due to an error.
        dismiss(dueTo: error, isClosing: true)

        // Unblock this view controller's UI.
        suspensionOverlay?.removeFromSuperview()
    }
}
