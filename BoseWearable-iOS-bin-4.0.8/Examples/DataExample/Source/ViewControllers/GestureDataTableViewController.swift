//
//  GestureDataTableViewController.swift
//  DataExample
//
//  Created by Paul Calnan on 10/23/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class GestureDataTableViewController: UITableViewController, GestureDataModelDelegate {

    var dataModel: GestureDataModel! {
        didSet {
            dataModel.delegate = self
        }
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        dataModel.clear()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gestureCell", for: indexPath)

        let (type, timestamp) = dataModel.element(at: indexPath.row)
        cell.textLabel?.text = type.description
        cell.detailTextLabel?.text = "Timestamp: \(timestamp.description)"

        return cell
    }

    func gestureDataModel(_ sender: GestureDataModel, addedElementAtIndex index: Int) {
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func gestureDataModelCleared(_ sender: GestureDataModel) {
        tableView.reloadData()
    }
}
