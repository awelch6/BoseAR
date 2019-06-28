//
//  CNCTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 4/29/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class CNCTableViewController: UITableViewController {

    var device: WearableDevice!

    private var cnc: ControllableNoiseCancellation?

    private var activityIndicator: ActivityIndicator?

    private var enabledSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        enabledSwitch = UISwitch(frame: CGRect())
        enabledSwitch.sizeToFit()
        enabledSwitch.addTarget(self, action: #selector(enabledSwitchChanged(_:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParent {
            device.getControllableNoiseCancellation(completionHandler: createCncHandler())
        }
    }

    private var hasData: Bool {
        return cnc != nil
    }

    private func createCncHandler() -> ((Result<ControllableNoiseCancellation>) -> Void) {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)

        return { [weak self] result in
            self?.activityIndicator?.removeFromSuperview()
            self?.activityIndicator = nil

            switch result {
            case .success(let cnc):
                self?.cnc = cnc

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
            label.text = "CNC Unavailable"
            label.sizeToFit()

            label.font = UIFont.systemFont(ofSize: 21)
            label.textAlignment = .center
            label.textColor = UIColor.darkGray

            tableView.backgroundView = label
        }

        enabledSwitch.isOn = cnc?.isEnabled ?? false
        tableView.reloadData()
    }

    @objc private func enabledSwitchChanged(_ sender: Any) {
        guard let current = cnc else {
            return
        }

        setCNC(level: current.currentLevel, isEnabled: !current.isEnabled)
    }

    private func setCNC(level: UInt8, isEnabled: Bool) {
        device.setControllableNoiseCancellation(level: level, isEnabled: isEnabled, completionHandler: createCncHandler())
    }

    // MARK: - Table view data source

    private let enabledSection = 0

    private let levelsSection = 1

    private let sectionCount = 2

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard hasData else {
            return 0
        }

        if cnc?.isEnabled ?? false {
            return sectionCount
        }
        else {
            return sectionCount - 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == levelsSection else {
            return nil
        }

        return "Levels"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enabledSection:
            return 1

        case levelsSection:
            return Int(cnc?.numberOfSteps ?? 0)

        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ?? UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")

        switch indexPath.section {
        case enabledSection:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Enabled"
                cell.accessoryView = enabledSwitch
            }
            cell.selectionStyle = .none

        case levelsSection:
            let level = indexPath.row
            let isCurrent: Bool

            if let currentLevel = cnc?.currentLevel {
                isCurrent = currentLevel == level
            }
            else {
                isCurrent = false
            }

            guard let numberOfSteps = cnc?.numberOfSteps else {
                break
            }

            // Adjust the name of the label to match the numbers reported by the voice prompts.
            //
            // If there are 11 levels...
            //
            // Level 0 in the API indicates the highest level of noise cancellation.
            // The voice prompts on the product will say it is Level 10.
            //
            // Level 10 in the API indicates the lowest level of noise cancellation.
            // The voice prompts on the product will say it is Level 0.
            //
            // Rather than show the API levels in the UI, we show the values that match
            // the voice prompts.
            let levelLabel = Int(numberOfSteps) - (level + 1)

            cell.textLabel?.text = "Level \(levelLabel)"
            cell.accessoryType = isCurrent ? .checkmark : .none
            cell.selectionStyle = .default

        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.section == levelsSection, indexPath.row <= UInt8.max else {
            return
        }

        setCNC(level: UInt8(indexPath.row), isEnabled: cnc?.isEnabled ?? false)
    }
}
