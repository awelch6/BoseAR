//
//  ANRTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 4/29/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class ANRTableViewController: UITableViewController {

    var device: WearableDevice!

    private var anr: ActiveNoiseReduction?

    private var activityIndicator: ActivityIndicator?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParent {
            device.getActiveNoiseReduction(completionHandler: createAnrHandler())
        }
    }

    private var hasData: Bool {
        return anr != nil
    }

    private func createAnrHandler() -> ((Result<ActiveNoiseReduction>) -> Void) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)

        return { [weak self] result in
            self?.activityIndicator?.removeFromSuperview()
            self?.activityIndicator = nil

            switch result {
            case .success(let anr):
                self?.anr = anr

            case .failure(let error):
                self?.show(error)
            }

            self?.reload()
        }
    }

    private func reload() {
        if hasData {
            tableView.backgroundView = nil
        }
        else {
            let label = UILabel(frame: CGRect.zero)
            label.text = "ANR Unavailable"
            label.sizeToFit()

            label.font = UIFont.systemFont(ofSize: 21)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray

            tableView.backgroundView = label
        }

        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasData ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anr?.availableModes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let mode = anr?.availableModes[indexPath.row]
        let isCurrent = anr?.currentMode == mode

        cell.textLabel?.text = mode?.description
        cell.accessoryType = isCurrent ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let mode = anr?.availableModes[indexPath.row] else {
            return
        }

        device.setActiveNoiseReduction(mode: mode, completionHandler: createAnrHandler())
    }
}
