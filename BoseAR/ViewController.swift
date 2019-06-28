//
//  ViewController.swift
//  BoseAR
//
//  Created by Austin Welch on 6/28/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import UIKit
import BoseWearable
import simd

class ViewController: UIViewController {

    var sensorDispatch = SensorDispatch(queue: .main)

    private var token: ListenerToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        SessionManager.shared.startConnection()
        SessionManager.shared.delegate = self
    }
}

// MARK: Setup Listeners

extension ViewController {
    private func listenForGestures(_ session: WearableDeviceSession) {
        session.device?.configureGestures({ (config) in
            config.disableAll()
            config.set(gesture: .doubleTap, enabled: true)
            config.set(gesture: .headNod, enabled: true)
        })
    }
    
    private func listenForSensors(_ session: WearableDeviceSession) {
        session.device?.configureSensors { config in
            // Here, config is the current sensor config. We begin by turning off
            // all sensors, allowing us to start with a "clean slate."
            config.disableAll()

            // Enable the rotation and accelerometer sensors
            config.enable(sensor: .rotation, at: ._20ms)
            config.enable(sensor: .accelerometer, at: ._20ms)
            config.enable(sensor: .gyroscope, at: ._20ms)
        }
    }
    
    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didWriteGestureConfiguration:
            print("did write gesture config")
        case .didUpdateGestureConfiguration:
            print("success updated gesture")
        case .didFailToWriteGestureConfiguration(let error):
            print("we have an err", error)
        default:
            print("default")
            break
        }
    }
}

extension ViewController: SessionManagerDelegate {
    func session(_ session: WearableDeviceSession, didOpen: Bool) {
        sensorDispatch.handler = self
        listenForSensors(session)
        listenForGestures(session)
        
        token = session.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }
}

extension ViewController: SensorDispatchHandler {
    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap

        let pitch = qResult.xRotation
        let roll = qResult.yRotation
        let yaw = -qResult.zRotation

        print("Pitch: \(pitch), Roll: \(roll), Yaw: \(yaw)")
    }


    func receivedGyroscope(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        let pitch = vector.x
        let roll = vector.y
        let yaw = vector.z
        
        print("Pitch: \(pitch), Roll: \(roll), Yaw: \(yaw)")
    }
    
    func receivedGesture(type: GestureType, timestamp: SensorTimestamp) {
        print(type)
    }
//    func receivedAccelerometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
//        xValue.text = format(decimal: vector.x)
//        yValue.text = format(decimal: vector.y)
//        zValue.text = format(decimal: vector.z)
//    }
}
