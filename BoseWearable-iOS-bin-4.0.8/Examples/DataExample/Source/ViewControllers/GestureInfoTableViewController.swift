//
//  GestureInfoTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 11/1/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class GestureInfoTableViewController: UITableViewController {

    var device: WearableDevice!

    private var token: ListenerToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        guard case .didUpdateGestureInformation = event else {
            return
        }

        refreshControl?.endRefreshing()
        reload()
    }

    @IBAction func refresh(_ sender: Any) {
        device.refreshGestureInformation()
    }

    private var hasData: Bool {
        return (device.gestureInformation?.availableGestures.count ?? 0) > 0
    }

    private func reload() {
        tableView.reloadData()

        if hasData {
            tableView.backgroundView = nil
        }
        else {
            let label = UILabel(frame: CGRect.zero)
            label.text = "Gesture Info Unavailable"
            label.sizeToFit()

            label.font = UIFont.systemFont(ofSize: 21)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray

            tableView.backgroundView = label
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasData ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return device.gestureInformation?.availableGestures.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let gesture = device.gestureInformation?.availableGestures[indexPath.row]
        cell.textLabel?.text = gesture?.description

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard hasData, section == 0 else {
            return nil
        }
        return "Available Gestures"
    }
}
