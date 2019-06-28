//
//  HeadingTableViewController.swift
//  HeadingExample
//
//  Created by Paul Calnan on 11/19/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import CoreLocation
import Logging
import simd
import UIKit
import WorldMagneticModel

class HeadingTableViewController: UITableViewController {

    // MARK: - Properties

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

    /// Alert dialog to prompt the user to put the device into pairing mode.
    private var pairingModePrompt: UIAlertController =
        UIAlertController(title: "Pairing Mode Required",
                          message: "Please put your Bose device into pairing mode",
                          preferredStyle: .alert)

    /// The CoreLocation manager for receiving location updates.
    private let locationManager = CLLocationManager()

    /// The current location.
    private var currentLocation: CLLocation?

    /// The World Magnetic Model that performs magnetic declination.
    private let worldMagneticModel: WMMModel = {
        do {
            return try WMMModel()
        }
        catch {
            fatalError("Could not load World Magnetic Model: \(error)")
        }
    }()

    /// The magnetic heading as reported by the Bose Wearable device. If this value is `nil`, no heading has been received yet.
    private var magneticHeadingDegrees: Double?

    /// The true heading is derived from the magnetic heading using the World Magnetic Model. If this value is `nil`, either the `magneticHeadingDegrees` or the `currentLocation` are nil.
    private var trueHeadingDegrees: Double? {
        // We can't compute the true heading if magnetic heading or current location is nil.
        guard let heading = magneticHeadingDegrees, let location = currentLocation else {
            return nil
        }

        // Compute the magnetic declination based on the current location
        let elem = worldMagneticModel.elements(for: location)
        let decl = elem.decl

        // The true heading is the magnetic heading plus the declination.
        return heading + decl
    }

    // MARK: - IBOutlets

    @IBOutlet var headingType: UISegmentedControl!
    @IBOutlet var headingValue: UILabel!
    @IBOutlet var headingAccuracyValue: UILabel!
    @IBOutlet var latValue: UILabel!
    @IBOutlet var lonValue: UILabel!
    @IBOutlet var altValue: UILabel!
    @IBOutlet var horizontalAccuracyValue: UILabel!
    @IBOutlet var verticalAccuracyValue: UILabel!
}

// MARK: - View lifecycle

extension HeadingTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // We set this object as the sensor dispatch handler in order to receive
        // sensor data.
        sensorDispatch.handler = self

        // Update the label font to use monospaced numbers.
        [headingValue, headingAccuracyValue, latValue, lonValue, altValue, horizontalAccuracyValue, verticalAccuracyValue].forEach {
            $0?.useMonospacedNumbers()
        }

        // Enable location services -- current location is required for WorldMagneticModel
        currentLocation = nil
        enableLocationServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If we are being pushed on to a navigation controller...
        if isMovingToParent {
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

    /**
     Error handler function called at various points in this class.  If an error
     occurred, show it in an alert. When the alert is dismissed, this function
     dismisses this view controller by popping to the root view controller (we are
     assumed to be on a navigation stack).
     */
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
}

// MARK: - Sensor management

extension HeadingTableViewController {

    /**
     Listen for incoming wearable device events. Retain the ListenerToken. When the ListenerToken is deallocated, this object is automatically removed as an event listener.
     */
    private func listenForWearableDeviceEvents() {

        token = session.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    /**
     We are only interested in the event that the sensor configuration could not be updated. In this case, show the error to the user. Otherwise, ignore the event.
     */
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

    /// Configures the rotation sensor at 50 Hz (a 20 ms sample period).
    private func listenForSensors() {
        session.device?.configureSensors { config in

            // Here, config is the current sensor config. We begin by turning off
            // all sensors, allowing us to start with a "clean slate."
            config.disableAll()

            // Enable the rotation and accelerometer sensors
            config.enable(sensor: .rotation, at: ._20ms)
        }
    }

    /// Disables all of the sensors.
    private func stopListeningForSensors() {
        session.device?.configureSensors { config in
            config.disableAll()
        }
    }
}

// MARK: - SensorDispatchHandler

// Note, we only have to implement the SensorDispatchHandler functions for the
// sensors we are interested in. These functions are called on the main queue
// as that is the queue provided to the SensorDispatch initializer.

extension HeadingTableViewController: SensorDispatchHandler {

    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {

        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap
        let yaw = -qResult.zRotation

        // The quaternion yaw value is the heading in radians. Convert to degrees.
        magneticHeadingDegrees = yaw * 180 / Double.pi
        updateHeadingDisplay(accuracy: accuracy)
    }
}

// MARK: - WearableDeviceSessionDelegate

extension HeadingTableViewController: WearableDeviceSessionDelegate {

    func sessionDidOpen(_ session: WearableDeviceSession) { }

    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {  }

    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        // The session was closed, possibly due to an error.
        dismiss(dueTo: error, isClosing: true)

        // Unblock this view controller's UI.
        suspensionOverlay?.removeFromSuperview()
    }
}

// MARK: - Location Services and CLLocationManagerDelegate

extension HeadingTableViewController: CLLocationManagerDelegate {

    /// Call this when the view loads to enable location services. Note that `NSLocationWhenInUseUsageDescription` must be defined in your Info.plist or the authorization status will be `.denied`.
    private func enableLocationServices() {
        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            Log.location.info("Requesting authorization to use location services")
            locationManager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            Log.location.info("Location services enabled")
            locationManager.startUpdatingLocation()

        case .restricted, .denied:
            fallthrough

        @unknown default:
            Log.location.info("Cannot enable location services")
            currentLocation = nil
        }
    }

    /// Delegate method called when the authorization status changes.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            Log.location.info("Location services authorized -- enabled")
            locationManager.startUpdatingLocation()

        case .notDetermined, .restricted, .denied:
            fallthrough

        @unknown default:
            Log.location.info("Location services not authorized -- disabled")
            currentLocation = nil
        }
    }

    /// Delegate method called when the location changes.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We are only interested in the last location in the array.
        guard let location = locations.last else {
            return
        }

        // Save and display the current location.
        Log.location.debug("CoreLocation location=\(location), altitude=\(location.altitude)")
        currentLocation = location
        updateLocationDisplay()
    }
}

// MARK: - Data Display

extension HeadingTableViewController {

    /**
     Displays the heading and heading accuracy.

     Uses the `magneticHeadingDegrees` value (set by the `SensorDispatchHandler`) or the `trueHeadingDegrees` value (which is derived from the `magneticHeadingDegrees` value) depending upon the selected mode (magnetic or true).
     */
    private func updateHeadingDisplay(accuracy: QuaternionAccuracy) {
        let heading =
            headingType.selectedSegmentIndex == 0
                ? magneticHeadingDegrees
                : trueHeadingDegrees

        // The desired heading value may be nil. See the documentation for `magneticHeadingDegrees` and `trueHeadingDegrees` to see why.
        if let h = heading {
            headingValue.text = format(degrees: h)
        }
        else {
            headingValue.text = "-"
        }

        headingAccuracyValue.text = format(radians: accuracy.estimatedAccuracy)
    }

    /// Displays the current location. Uses the `currentLocation` value.
    private func updateLocationDisplay() {
        guard let loc = currentLocation else {
            latValue.text = "-"
            lonValue.text = "-"
            altValue.text = "-"

            return
        }

        // A negative horizontal accuray means the latitude and longitude are invalid
        if loc.horizontalAccuracy < 0 {
            latValue.text = "invalid"
            lonValue.text = "invalid"
            horizontalAccuracyValue.text = "invalid"
        }
        else {
            latValue.text = String(format: "%.04f°", loc.coordinate.latitude)
            lonValue.text = String(format: "%.04f°", loc.coordinate.longitude)
            horizontalAccuracyValue.text = String(format: "±%.02f m", loc.horizontalAccuracy)
        }

        // A negative vertical accuracy means the altitude is invalid
        if loc.verticalAccuracy < 0 {
            altValue.text = "invalid"
            verticalAccuracyValue.text = "invalid"
        }
        else {
            altValue.text = String(format: "%.02f m", loc.altitude)
            verticalAccuracyValue.text = String(format: "±%.02f m", loc.verticalAccuracy)
        }
    }
}
