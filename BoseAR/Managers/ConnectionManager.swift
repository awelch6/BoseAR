//
//  ConnectionManager.swift
//  BoseAR
//
//  Created by Austin Welch on 6/28/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import BoseWearable

public typealias ConnectManagerCompletion = ((WearableDeviceSession?, Error?) -> Void)

struct ConnectionManager {
    
    public static func startConnection(_ completion: @escaping ConnectManagerCompletion) {
        
        let sensorIntent = SensorIntent(sensors: [.rotation, .accelerometer], samplePeriods: [._20ms])
        
        // Perform the device search and connect to the selected device. This
        // may present a view controller on a new UIWindow.
        BoseWearable.shared.startConnection(mode: .alwaysShow, sensorIntent: sensorIntent) { result in
            switch result {
            case .success(let session):
                // A device was selected, a session was created and opened. Show
                // a view controller that will become the session delegate.
                completion(session, nil)
            case .failure(let error):
                // An error occurred when searching for or connecting to a
                // device. Present an alert showing the error.
                completion(nil, error)
            case .cancelled:
                // The user cancelled the search operation.
                completion(nil, WearableSessionError.userCancel)
                break
            }
        }
    }
}
