//
//  SettingsViewController.swift
//  SceneExample
//
//  Created by George Persiantsev on 8/23/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var orientationSwitch: UISwitch!
    @IBOutlet weak var mirrorSwitch: UISwitch!

    var sceneView: SceneViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        orientationSwitch.isOn = Preferences.shared.get(.correctForBaseReading)
        mirrorSwitch.isOn = Preferences.shared.get(.mirror)
    }

    @IBAction func resetOrientation(_ sender: UIButton) {
        sceneView?.resetOrientation()
    }

    @IBAction func settingChanged(_ sender: UISwitch) {
        let key: Preferences.Key

        switch sender {
        case orientationSwitch:
            key = .correctForBaseReading
        case mirrorSwitch:
            key = .mirror
        default:
            return
        }

        Preferences.shared.set(key, to: sender.isOn)
    }
}
