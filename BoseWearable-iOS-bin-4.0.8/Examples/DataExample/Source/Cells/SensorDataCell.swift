//
//  SensorDataCell.swift
//  DataExample
//
//  Created by Paul Calnan on 10/15/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import simd
import UIKit

class SensorDataCell: UITableViewCell {

    var enabledSwitchChanged: ((Bool) -> Void)?

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var enabledSwitch: UISwitch!

    @IBOutlet var valueLabelContainer: UIView!

    @IBOutlet var xValue: UILabel?

    @IBOutlet var yValue: UILabel?

    @IBOutlet var zValue: UILabel?

    @IBOutlet var wValue: UILabel?

    @IBOutlet var pitchValue: UILabel?

    @IBOutlet var rollValue: UILabel?

    @IBOutlet var yawValue: UILabel?

    @IBOutlet var xBiasValue: UILabel?

    @IBOutlet var yBiasValue: UILabel?

    @IBOutlet var zBiasValue: UILabel?

    @IBOutlet var timestampValue: UILabel!

    @IBOutlet var accuracyValue: UILabel?

    @IBOutlet var observedFrequencyValue: UILabel!

    @IBOutlet var accuracyLabels: [UILabel]?

    @IBOutlet var valueLabels: [UILabel]!

    override func awakeFromNib() {
        super.awakeFromNib()
        setSensorEnabled(false)

        valueLabels.forEach {
            $0.useMonospacedNumbers()
        }
    }

    func configure(for sensor: SensorType) {
        titleLabel.text = sensor.description

        let hideAccuracyLabels = (sensor == .gameRotation)
        accuracyLabels?.forEach { $0.isHidden = hideAccuracyLabels }

        switch sensor {
        case .accelerometer, .gyroscope, .orientation, .magnetometer:
            update(vector: Vector(0, 0, 0))
            update(vectorAccuracy: .unreliable)

        case .rotation:
            update(quaternion: Quaternion(ix: 0, iy: 0, iz: 0, r: 0))
            update(quaternionAccuracy: QuaternionAccuracy(estimatedAccuracy: 0))

        case .gameRotation:
            update(quaternion: Quaternion(ix: 0, iy: 0, iz: 0, r: 0))

        case .uncalibratedMagnetometer:
            update(vector: Vector(0, 0, 0))
            update(bias: Vector(0, 0, 0))
        }

        update(timestamp: 0)
    }

    @IBAction func enabledSwitchChanged(_ sender: Any) {
        enabledSwitchChanged?(enabledSwitch.isOn)
        toggleSensorValues()
    }

    func setSensorEnabled(_ isEnabled: Bool) {
        enabledSwitch.isOn = isEnabled
        toggleSensorValues()
    }

    private func toggleSensorValues() {
        let color = enabledSwitch.isOn ? UIColor.black : UIColor.lightGray

        SensorDataCell.findLabels(in: valueLabelContainer).forEach {
            $0.textColor = color
        }
    }

    private static func findLabels(in view: UIView) -> [UILabel] {
        var labels: [UILabel] = []
        for subview in view.subviews {
            if !(subview is UIButton) {
                labels.append(contentsOf: findLabels(in: subview))
            }

            if let label = subview as? UILabel {
                labels.append(label)
            }
        }
        return labels
    }

    func update(with value: SensorValue) {
        if let v = value.sample.vector {
            update(vector: v)
        }
        else if let q = value.sample.quaternion {
            update(quaternion: q)
        }

        if let b = value.sample.bias {
            update(bias: b)
        }

        if let v = value.sample.vectorAccuracy {
            update(vectorAccuracy: v)
        }
        else if let q = value.sample.quaternionAccuracy {
            update(quaternionAccuracy: q)
        }

        update(timestamp: value.timestamp)
    }

    func update(vector v: Vector) {
        xValue?.text = Format.decimal(v.x)
        yValue?.text = Format.decimal(v.y)
        zValue?.text = Format.decimal(v.z)
    }

    func update(vectorAccuracy a: VectorAccuracy) {
        accuracyValue?.text = a.description
    }

    func update(quaternion q: Quaternion) {
        xValue?.text = Format.decimal(q.x)
        yValue?.text = Format.decimal(q.y)
        zValue?.text = Format.decimal(q.z)
        wValue?.text = Format.decimal(q.w)

        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = q * qMap

        let pitch = qResult.xRotation
        let roll = -qResult.yRotation
        let yaw = -qResult.zRotation

        pitchValue?.text = Format.degrees(radians: pitch)
        rollValue?.text = Format.degrees(radians: roll)
        yawValue?.text = Format.degrees(radians: yaw)
    }

    func update(quaternionAccuracy a: QuaternionAccuracy) {
        accuracyValue?.text = Format.degrees(radians: a.estimatedAccuracy)
    }

    func update(bias b: Vector) {
        xBiasValue?.text = Format.decimal(b.x)
        yBiasValue?.text = Format.decimal(b.y)
        zBiasValue?.text = Format.decimal(b.z)
    }

    func update(timestamp t: SensorTimestamp) {
        timestampValue.text = t.description
    }
}
