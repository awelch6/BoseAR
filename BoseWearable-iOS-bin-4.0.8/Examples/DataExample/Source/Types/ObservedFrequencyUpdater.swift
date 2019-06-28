//
//  ObservedFrequencyUpdater.swift
//  DataExample
//
//  Created by Paul Calnan on 8/17/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import UIKit

/**
 Utility class to count incoming reports.

 - Call `start()` to start the one-second update timer.
 - Call `updateReceived()` to increment the count.
 - When the timer fires, the label passed to the initializer is updated with the count. The count is then reset.
 - Call `stop()` to stop the update timer.
 */
class ObservedFrequencyUpdater {

    /// Support class for computing a moving average of the observed frequency.
    private class MovingAverage {

        /// Circular buffer of values.
        private var samples: [Int]

        /// Number of samples received.
        private var sampleCount = 0

        /// The period of the moving average. Implies the size of the circular buffer.
        private let period: Int

        /// Create a new instance.
        init(period: Int) {
            self.period = period
            samples = [Int](repeating: 0, count: period)
        }

        /// The current average.
        var average: Double {
            let n = Double(samples.reduce(0, +))
            let d = Double(min(sampleCount, period))
            return n / d
        }

        /// Adds a sample and returns the average.
        func addSample(_ sample: Int) -> Double {
            samples[sampleCount % period] = sample
            sampleCount += 1
            return average
        }
    }

    /// The timer that fires once a second to update the label.
    private var timer: Timer?

    /// The number of updates received. This is reset to 0 once a second, making it equal to the observed frequency over the last second.
    private var updateCount = 0

    /// The label to update with the frequency.
    private let label: UILabel

    /// Keep a moving average of frequencies here and include in the display label once a second.
    private let movingAverage = MovingAverage(period: 6)

    /// Create a new object that updates the specified label.
    init(label: UILabel) {
        self.label = label
    }

    /// Automatically stop the updater when deallocating.
    deinit {
        stop()
    }

    /// Starts the one-second update timer.
    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateObservedFrequency), userInfo: nil, repeats: true)
    }

    /// Stops the one-second update timer.
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Called to indicate that an update has been received. Increments the update count.
    func updateReceived() {
        updateCount += 1
    }

    /// Called when the timer fires. Updates the moving average, the UI, and resets the update counter.
    @objc private func updateObservedFrequency() {
        let avg = movingAverage.addSample(updateCount)

        label.text = String(format: "%d (avg %0.1f) Hz", updateCount, avg)
        updateCount = 0
    }
}
