//
//  GestureConfigTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 10/23/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class GestureConfigTableViewController: UITableViewController {

    var device: WearableDevice!

    private var allGestures = [GestureType]()

    private var token: ListenerToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didUpdateGestureConfiguration:
            refreshControl?.endRefreshing()
            configurationChangeComplete()
            reload()

        case .didFailToWriteGestureConfiguration(let error):
            configurationChangeComplete()
            show(error)

        default:
            break
        }
    }

    @IBAction func refresh(_ sender: Any) {
        device.refreshGestureConfiguration()
    }

    private func reload() {
        allGestures = Array(device.wearableDeviceInformation?.availableGestures ?? []).sorted {
            $0.rawValue < $1.rawValue
        }

        tableView.reloadData()

        if hasData {
            tableView.backgroundView = nil
        }
        else {
            let label = UILabel(frame: CGRect.zero)
            label.text = "Gesture Config Unavailable"
            label.sizeToFit()

            label.font = UIFont.systemFont(ofSize: 21)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray

            tableView.backgroundView = label
        }
    }

    // MARK: - Table view data source

    private var hasData: Bool {
        return !allGestures.isEmpty
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasData ? 2 : 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard hasData, section == 0 else {
            return nil
        }
        return "Gestures"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard hasData, section == 0 else {
            return nil
        }
        return "Select a gesture to enable or disable."
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return allGestures.count
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "gestureCell", for: indexPath)

            let gesture = allGestures[indexPath.row]
            let isEnabled = device.gestureConfiguration?.isEnabled(gesture: gesture) ?? false

            cell.textLabel?.text = gesture.description
            cell.accessoryType = isEnabled ? .checkmark : .none

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)

            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Enable all gestures"
            case 1:
                cell.textLabel?.text = "Disable all gestures"
            default:
                cell.textLabel?.text = nil
            }
            return cell

        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let gesture = allGestures[indexPath.row]
            toggle(gesture)

        case 1:
            switch indexPath.row {
            case 0:
                setAllGestures(enabled: true)

            case 1:
                setAllGestures(enabled: false)

            default:
                break
            }

        default:
            break
        }
    }

    private func isEnabled(_ gesture: GestureType) -> Bool {
        return device.gestureConfiguration?.isEnabled(gesture: gesture) ?? false
    }

    private func toggle(_ gesture: GestureType) {
        set(gesture, enabled: !isEnabled(gesture))
    }

    private var activityIndicator: ActivityIndicator?

    private func set(_ gesture: GestureType, enabled: Bool) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureGestures { config in
            config.set(gesture: gesture, enabled: enabled)
        }
    }

    private func setAllGestures(enabled: Bool) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
        device.configureGestures { config in
            if enabled {
                config.enableAll()
            }
            else {
                config.disableAll()
            }
        }
    }

    private func configurationChangeComplete() {
        activityIndicator?.removeFromSuperview()
    }
}
