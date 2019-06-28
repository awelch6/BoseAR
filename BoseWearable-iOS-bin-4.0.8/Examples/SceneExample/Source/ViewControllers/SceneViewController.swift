//
//  SceneViewController.swift
//  SceneExample
//
//  Created by Paul Calnan on 7/16/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import Logging
import SceneKit
import UIKit

/// Stored preferences.
class Preferences {

    /// Singleton instance.
    static let shared = Preferences()

    /// UserDefaults keys
    enum Key: String {
        case correctForBaseReading
        case mirror
    }

    /// Default values for the preferences
    private let defaults: [Key: Any?] = [
        .correctForBaseReading: true,
        .mirror: true
    ]

    /// Stores the value for the specified key.
    func set<T>(_ key: Key, to value: T?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    /// Retrieves the value for the specified key.
    func get<T>(_ key: Key) -> T {
        if let val = UserDefaults.standard.object(forKey: key.rawValue) as? T {
            return val
        }
        if let defaultVal = defaults[key] as? T {
            return defaultVal
        }
        fatalError("All keys must have defaults!")
    }
}

class SceneViewController: UIViewController {
    enum RotationMode {
        case rotationVector
        case gameRotationVector

        var sensor: SensorType {
            switch self {
            case .rotationVector:
                return .rotation
            case .gameRotationVector:
                return .gameRotation
            }
        }
    }

    private enum Constants {
        // Config
        static let showDebugInfo = false // print out angles, position, etc. data of camera and root object
        static let manuallyControlModel = false // swipe, pinch, etc. to change camera position

        // Consts
        static let halfPi = Float.pi / 2
    }

    var rotationMode: RotationMode = .rotationVector

    @IBOutlet var sceneView: SCNView!

    @IBOutlet var accuracyLabel: UILabel!

    var sensorDispatch = SensorDispatch(queue: .main)

    // The session is set by the HomeViewController before this view controller is shown.
    // When this view controller is popped and deallocated, the session will be released and deallocated. This will cause the connection to be closed.
    var session: WearableDeviceSession! {
        didSet {
            session?.delegate = self
        }
    }

    var isSimulated = false

    var token: ListenerToken?

    private let rotation = Quaternion(from: Vector(x: 0, y: -1, z: 0), to: Vector(x: 0, y: 0, z: 1))

    private var baseReadings: Quaternion?

    override func viewDidLoad() {
        super.viewDidLoad()

        accuracyLabel.useMonospacedNumbers()

        sensorDispatch.gameRotationCallback = { [weak self] quaternion, timestamp in
            guard self?.rotationMode == .gameRotationVector else {
                return
            }
            self?.update(quaternion, nil, timestamp)
        }

        sensorDispatch.rotationCallback = { [weak self] quaternion, accuracy, timestamp in
            guard self?.rotationMode == .rotationVector else {
                return
            }
            self?.update(quaternion, accuracy, timestamp)
        }

        sensorDispatch.gestureDataCallback = { [weak self] gesture, timestamp in
            guard case .input = gesture else {
                return
            }
            self?.resetOrientation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParent {
            token = session.device?.addEventListener(queue: .main) { [weak self] event in
                self?.wearableDeviceEvent(event)
            }

            // Now that the session has opened use the product information to update the sceneView
            let productID = session.device?.wearableDeviceInformation?.productID ?? 0
            let variant = session.device?.wearableDeviceInformation?.variant ?? 0
            let scene = self.scene(forProduct: productID, variant: variant)

            sceneView.scene = scene

            // have the SceneView create the default point of view camera, then turn user control off
            sceneView.allowsCameraControl = true
            sceneView.allowsCameraControl = Constants.manuallyControlModel

            // set default camera "zoom"
            sceneView.pointOfView?.camera?.fieldOfView = 73

            configureSensors(enable: true)
        }
    }

    private var suspensionOverlay: SuspensionOverlay?

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didFailToWriteSensorConfiguration(let error):
            show(error)

        case .didSuspendWearableSensorService(let reason):
            suspensionOverlay = SuspensionOverlay.add(to: navigationController?.view, reason: reason)

        case .didResumeWearableSensorService:
            suspensionOverlay?.removeFromSuperview()
            suspensionOverlay = nil

        default:
            return
        }
    }

    private func configureSensors(enable: Bool) {
        session.device?.configureSensors { config in
            config.disableAll()

            if enable {
                config.enable(sensor: rotationMode.sensor, at: ._20ms)
            }
        }

        session.device?.configureGestures { config in
            config.disableAll()
            config.set(gesture: .input, enabled: true)
        }
    }

    private var receivedInitialReading = false

    private func update(_ quaternion: Quaternion, _ accuracy: QuaternionAccuracy?, _ timestamp: SensorTimestamp) {

        if !receivedInitialReading {
            receivedInitialReading = true
            resetOrientation()

            return
        }

        accuracyLabel.text = "Accuracy: \(format(radians: accuracy?.estimatedAccuracy ?? 0))"

        guard let root = sceneView.scene?.rootNode else {
            return
        }

        // Map to the SCNNode (model) coordinate system. If using a simulated device use a different mapping for proper orientation.
        let qMap = Quaternion(ix: 0, iy: 1, iz: isSimulated ? 1 : 0, r: 0)

        // Apply map on the right hand side!
        var qResult = quaternion * qMap

        if baseReadings == nil {
            baseReadings = Preferences.shared.get(.correctForBaseReading) ?
                qResult.inverse : Quaternion(ix: 0, iy: 0, iz: 0, r: 1)
        }

        guard let base = baseReadings else {
            return
        }

        // Apply calibration on left hand side!
        qResult = base * qResult

        if Preferences.shared.get(.mirror) == true {
            // Move to left handed coordinate system
            qResult.imag.y = -qResult.imag.y
            qResult.imag.z = -qResult.imag.z
        }

        root.simdOrientation = qResult.quatf

        if Constants.showDebugInfo {
            guard let pov = sceneView.pointOfView else {
                return
            }

            guard let root = sceneView.scene?.rootNode else {
                return
            }

            Log.debug("Camera position: \(pov.position.x), \(pov.position.y), \(pov.position.z)")
            Log.debug("Camera rotation: \(pov.rotation.x), \(pov.rotation.y), \(pov.rotation.z), \(pov.rotation.w)")
            Log.debug("Camera orientation: \(pov.orientation.x), \(pov.orientation.y), \(pov.orientation.z), \(pov.orientation.w)")
            Log.debug("Camera Euler angles: \(pov.eulerAngles.x), \(pov.eulerAngles.y), \(pov.eulerAngles.z)")
            Log.debug("Root Euler angles: \(root.eulerAngles.x), \(root.eulerAngles.y), \(root.eulerAngles.z)")
            Log.debug("Camera field of view: \(pov.camera?.fieldOfView ?? 0.0)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }

        guard
            segue.identifier == "showSettings",
            let vc = segue.destination as? SettingsViewController
        else {
            return
        }

        vc.sceneView = self
    }

    func resetOrientation() {
        guard receivedInitialReading else {
            return
        }

        baseReadings = nil
    }
}

extension SceneViewController: WearableDeviceSessionDelegate {

    func sessionDidOpen(_ session: WearableDeviceSession) {  }

    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) { }

    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        guard let error = error else {
            navigationController?.popToRootViewController(animated: true)
            return
        }

        show(error) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
