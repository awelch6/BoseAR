//
//  HomeViewController.swift
//  SceneExample
//
//  Created by Paul Calnan on 7/16/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

/// This view controller is the initial screen in the example app. It provides buttons allowing the user to open a session with a device.
class HomeViewController: UITableViewController {

    @IBOutlet var rotationSource: UISegmentedControl!

    @IBOutlet var connectToLast: UISwitch!

    private var activityIndicator: ActivityIndicator?

    @IBOutlet var versionLabel: UILabel!

    private var mode: ConnectUIMode {
        return connectToLast.isOn
            ? .connectToLast(timeout: 5)
            : .alwaysShow
    }

    private var rotationMode: SceneViewController.RotationMode {
        switch rotationSource.selectedSegmentIndex {
        case 0:
            return .rotationVector
        case 1:
            return .gameRotationVector
        default:
            fatalError("Invalid rotation mode selected")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "BoseWearable \(BoseWearable.formattedVersion)"
    }

    @IBAction func connectTapped(_ sender: Any) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)

        let sensorIntent = SensorIntent(sensors: [rotationMode.sensor], samplePeriods: [._20ms])
        let gestureIntent = GestureIntent(gestures: [.input])

        BoseWearable.shared.startConnection(mode: mode, sensorIntent: sensorIntent, gestureIntent: gestureIntent) { result in
            switch result {
            case .success(let session):
                self.showScene(with: session)

            case .failure(let error):
                self.show(error)

            case .cancelled:
                break
            }

            self.activityIndicator?.removeFromSuperview()
        }
    }

    @IBAction func useSimulatedAttitudeTapped(_ sender: Any) {
        showScene(with: BoseWearable.shared.createSimulatedWearableDeviceSession(), isSimulated: true)
    }

    private func showScene(with session: WearableDeviceSession, isSimulated: Bool = false) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SceneViewController") as? SceneViewController else {
            fatalError("Cannot instantiate view controller")
        }

        vc.rotationMode = rotationMode
        vc.session = session
        vc.isSimulated = isSimulated
        show(vc, sender: self)
    }
}
