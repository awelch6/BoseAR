//
//  GestureDataModel.swift
//  DataExample
//
//  Created by Paul Calnan on 10/23/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import Foundation

///
protocol GestureDataModelDelegate: class {
    func gestureDataModel(_ sender: GestureDataModel, addedElementAtIndex index: Int)
    func gestureDataModelCleared(_ sender: GestureDataModel)
}

/// The gesture data model accumulates gestures independent of the user interface. This allows the app to collect gestures at any time and display them on demand.
class GestureDataModel {

    /// Used to receive gesture data.
    private let sensorDispatch = SensorDispatch(queue: .main)

    /// Typealias to simplify subsequent declarations.
    private typealias Element = (GestureType, SensorTimestamp)

    /// The contents of the model.
    private var values: [Element] = []

    /// The delegate that gets notified when the data model updates.
    weak var delegate: GestureDataModelDelegate?

    /// Creates a new gesture data model.
    init() {
        sensorDispatch.gestureDataCallback = { [weak self] type, timestamp in
            self?.add((type, timestamp))
        }
    }

    /// Appends the specified value and notifies the delegate.
    private func add(_ item: Element) {
        values.append(item)
        delegate?.gestureDataModel(self, addedElementAtIndex: values.count - 1)
    }

    /// Returns the data at the specified index.
    func element(at index: Int) -> (GestureType, SensorTimestamp) {
        return values[index]
    }

    /// Returns the number of elements in the model.
    var count: Int {
        return values.count
    }

    /// Removes all values from the model and notifies the delegate
    func clear() {
        values = []
        delegate?.gestureDataModelCleared(self)
    }
}
