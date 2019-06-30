//
//  ConnectionManager.swift
//  BoseAR
//
//  Created by Austin Welch on 6/28/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import BoseWearable

typealias ConnectManagerCompletion = ((WearableDeviceSession?, Error?) -> Void)

protocol SessionManagerDelegate: class {
    func session(_ session: WearableDeviceSession, didOpen: Bool)
}

class SessionManager {
    
    static let shared = SessionManager()
    
    private(set) public var session: WearableDeviceSession?
    
    weak var delegate: SessionManagerDelegate?
    
    public func startConnection() {
        
        let gestureIntent = GestureIntent(gestures: [.doubleTap, .headNod])
       // let sensorIntent = SensorIntent(sensors: [.rotation, .accelerometer], samplePeriods: [._20ms])
        
        // Perform the device search and connect to the selected device. This
        // may present a view controller on a new UIWindow.
        //sensorIntent: sensorIntent,
        //.connectToLast(timeout: 5)
        BoseWearable.shared.startConnection(mode:.alwaysShow ,  gestureIntent: gestureIntent) { [weak self] result in
            switch result {
            case .success(let session):
                // A device was selected, a session was created and opened. Show
                // a view controller that will become the session delegate.
                self?.session = session
                self?.session?.delegate = self
                self?.delegate?.session(session, didOpen: true)
                
            case .failure(let error):
                // An error occurred when searching for or connecting to a
                // device. Present an alert showing the error.
                print("Did fail to connect \(error.localizedDescription)")
            case .cancelled:
                print("Connection Cancelled")
                // The user cancelled the search operation.
                break
            }
        }
    }
}

extension SessionManager: WearableDeviceSessionDelegate {
    func sessionDidOpen(_ session: WearableDeviceSession) {
        //We don't need to use this function.
        print("Session started")
    }
    
    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {
        // Have to restart connection when this happens
        print("Session fail to open with error \(error?.localizedDescription ?? "Failed to open.")")
    }
    
    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        // Have to restart connection when this happens
        print("Session did close with error \(error?.localizedDescription ?? "Closed with some error")")
    }
}
