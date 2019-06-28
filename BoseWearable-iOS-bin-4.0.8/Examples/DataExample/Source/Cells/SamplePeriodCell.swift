//
//  SamplePeriodCell.swift
//  DataExample
//
//  Created by Paul Calnan on 10/12/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

class SamplePeriodCell: UITableViewCell {

    var changeButtonTapped: (() -> Void)?

    @IBOutlet var samplePeriodLabel: UILabel!

    @IBOutlet var changeSamplePeriodButton: UIButton!

    @IBAction func changeSamplePeriodButtonTapped(_ sender: Any) {
        changeButtonTapped?()
    }

    func setSamplePeriod(_ milliseconds: UInt16) {
        let hz = milliseconds != 0 ? Double(1000) / Double(milliseconds) : 0
        samplePeriodLabel?.text = "\(milliseconds) ms (\(hz) Hz)"
    }
}
