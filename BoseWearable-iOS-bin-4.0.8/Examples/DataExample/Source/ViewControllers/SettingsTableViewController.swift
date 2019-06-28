//
//  SettingsTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 4/29/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class SettingsTableViewController: UITableViewController {

    var device: WearableDevice!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            super.prepare(for: segue, sender: sender)
        }

        switch segue.identifier {
        case "showANR":
            guard let vc = segue.destination as? ANRTableViewController else {
                return
            }
            vc.device = device

        case "showCNC":
            guard let vc = segue.destination as? CNCTableViewController else {
                return
            }
            vc.device = device

        default:
            return
        }
    }
}
