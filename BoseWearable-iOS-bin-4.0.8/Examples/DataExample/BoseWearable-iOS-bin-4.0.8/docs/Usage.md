# Usage

This document describes how to use the Bose Wearable SDK in your app.

- [Client App Requirements](#client-app-requirements)
- [Configuring and Initializing the Library](#configuring-and-initializing-the-library)
- [Creating and Opening a Session](#creating-and-opening-a-session)
- [Listening for Connection Events](#listening-for-connection-events)
- [Configuring Sensors](#configuring-sensors)
- [Configuring Gestures](#configuring-gestures)
- [Configuration Example](#configuration-example)
- [Listening for Sensor Data](#listening-for-sensor-data)
- [Combined Example](#combined-example)

## Client App Requirements

The Bose Wearable SDK uses Bluetooth to communicate with a wearable device. As such, Apple requires you add an `NSBluetoothPeripheralUsageDescription` entry to your `Info.plist` file explaining why your app uses Bluetooth. For example:

```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to communicate with Bose Wearable devices</string>
```

Additionally, if you want to be able to communicate with a BoseWearable device while your app is in the background, you should add the following `UIBackgroundModes` entry to your `Info.plist` file:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

## Configuring and Initializing the Library

Before using the Bose Wearable library, you will need to call `BoseWearable.configure(_:)`. We recommend doing so in your app delegate. For example:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // ...

    // Configure the BoseWearable SDK.
    BoseWearable.configure()

    // Enable common logging categories. Remove this from production code.
    BoseWearable.enableCommonLogging()

    // ...

    return true
}
```

The `BoseWearable.configure(_:)` method takes an optional dictionary containing configuration parameters. See the documentation for more details.

## Creating and Opening a Session

Use `BoseWearable.startConnection(mode:sensorIntent:gestureIntent:completionHander:)` to quickly and easily establish a connection with a wearable device.

```swift
// Perform the device search and connect to the selected device. This may
// present a view controller on a new UIWindow.
BoseWearable.shared.startConnection(mode: mode) { result in

    switch result {
    case .success(let session):
        // A device was selected, a session was created and opened. Show a view
        // controller that will become the session delegate.
        self.showViewController(for: session)

    case .failure(let error):
        // An error occurred when searching for or connecting to a device.
        // Present an alert showing the error.
        self.show(error)

    case .cancelled:
        // The user cancelled the search operation.
        break
    }
}
```

## Listening for Connection Events

You can use the `WearableDeviceSessionDelegate` protocol to listen for connection events. Assign a delegate to the `WearableDeviceSession.delegate` property to receive those events. For example:

```swift

extension ExampleClass: WearableDeviceSessionDelegate {

    func sessionDidOpen(_ session: WearableDeviceSession) {
        // Session opened successfully. Note that the session passed to the
        // startConnection completion handler is already open. This delegate
        // method is only useful when re-opening a session.
    }

    func session(_ session: WearableDeviceSession, didFailToOpenWithError error: Error?) {
        // The session failed to open. Present the error to the user. As above,
        // the session passed to the startConnection completion handler is
        // already open. This delegate method is only useful when re-opening a
        // session.
        show(error)
    }

    func session(_ session: WearableDeviceSession, didCloseWithError error: Error?) {
        // The session closed. If error is nil, this was an expected closure
        // (e.g., the connection was requested to be closed).

        if error != nil {
            show(error)
        }
    }
}
```

## Reconnecting to a Device

In the event that a session has closed, you will be notified via the `WearableDeviceSessionDelegate.session(_:didCloseWithError:)` delegate function. To re-establish communication with the remote device, you can do one of two things:

1. You can call `WearableDeviceSession.open()` to open the connection again. Note that if the session was closed due to the remote device being powered down or moved out of range, it must be powered back on or moved back into range in order for this to succeed. You will be notified on the `WearableDeviceSessionDelegate` whether this call to `open()` has succeeded (via `WearableDeviceSessionDelegate.sessionDidOpen(_:)`) or failed (via `WearableDeviceSessionDelegate.session(_:didFailToOpenWithError:)`).
2. You can perform another device search. Note that you must first release the closed `WearableDeviceSession` by setting any retained references to `nil`.

## Configuring Sensors

### Sensor Information

A `WearableDevice` provides a `WearableDevice.sensorInformation` property that contains information about the sensors available on the device. Of particular interest to client applications is the `SensorInformation.availableSensors` array that identifies which sensors are available on the device and the `SensorInformation.availableSamplePeriods` array that identifies which sample periods are available for use with the available sensors. The SDK fires a `WearableDeviceEvent.didUpdateSensorInformation(_:)` whenever this property changes.

### Sensor Configuration

A `WearableDevice` also provides a `WearableDevice.sensorConfiguration` property that contains the current configuration of its sensors. This indicates which sensors are enabled and the sample period for those enabled sensors. The SDK fires a `WearableDeviceEvent.didUpdateSensorConfiguration(_:)` event whenever this property changes.

The `SensorConfiguration` object allows you to do any of the following in a single shot:

- Enable sensors at a specified sample period (see `SensorConfiguration.enable(sensor:at:)`)
- Disable sensors (see `SensorConfiguration.disable(sensor:)`)
- Change the sample period for all currently-enabled sensors (see `SensorConfiguration.enabledSensorsSamplePeriod`)

Upon connection to a wearable device, all sensors are disabled. The client application must configure the sensors appropriately. This can be done via the `WearableDevice.configureSensors(_:)` function.

If the device accepts the new configuration, a `WearableDeviceEvent.didWriteSensorConfiguration` event is fired followed by a `WearableDeviceEvent.didUpdateSensorConfiguration(_:)` event containing the updated sensor configuration. If the device does not accept the new configuration, a `WearableDeviceEvent.didFailToWriteSensorConfiguration(_:)` is fired with an error object that indicates the cause of the failure.

The [Configuration Example](#configuration-example) below shows how to use this feature.

## Configuring Gestures

### Gesture Information

A `WearableDevice` provides a `WearableDevice.gestureInformation` property that contains information about the gestures that are available on the device. Of particular interest to client applicatons is the `GestureInformation.availableGestures` array that identifies which gestures are available on the device. The SDK fires a `WearableDeviceEvent.didUpdateGestureInformation(_:)` whenever this property changes.

### Gesture Configuration

A `WearableDevice` also provides a `WearableDevice.gestureConfiguration` property that contains the current configuration of its gestures. This indicates which gestures are enabled. The SDK fires a `WearableDeviceEvent.didUpdateGestureConfiguration(_:)` whenever this property changes.

The `GestureConfiguration` object allows you to enable or disable supported gestures.

Upon connection to a wearable device, all gestures are disabled by default. The client application must configure the gestures appropriately. This can be done via the `WearableDevice.configureGestures(_:)` function.

If the device accepts the new configuration, a `WearableDeviceEvent.didWriteGestureConfiguration` event is fired followed by a `WearableDeviceEvent.didUpdateGestureConfiguration(_:)` event containing the updated gesture configuration. If the device does not accept the new configuration, a `WearableDeviceEvent.didFailToWriteGestureConfiguration(_:)` is fired with an error object that indicates the cause of the failure.

The [Configuration Example](#configuration-example) below shows how to use this feature.

## Configuration Example

Consider an application that wants to:

- Enable both the accelerometer and gyroscope at 50 Hz (this corresponds to a 20 ms update period).
- Enable the double-tap gesture.

```swift
import BoseWearable

class ExampleClass {

    private let device: WearableDevice

    private var token: ListenerToken?

    init(device: WearableDevice) {
        self.device = device

        // Listen for WearableDeviceEvents.
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }

    func configureSensors() {
        device.configureSensors { config in
            // First, disable all currently-enabled sensors.
            config.disableAll()

            // Next, configure the sensors we are interested in.
            config.enable(sensor: .accelerometer, at: ._20ms)
            config.enable(sensor: .gyroscope, at: ._20ms)
        }
    }

    func configureGestures() {
        device.configureGestures { config in
            // First, disable all currently-enabled gestures.
            config.disableAll()

            // Next, configure the gestures we are interested in.
            config.set(gesture: .doubleTap, enabled: true)
        }
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didWriteSensorConfiguration:
            // The sensor configuration change was accepted.

        case .didFailToWriteSensorConfiguration(let error):
            // The sensor configuration change was rejected with the specified error.

        case .didWriteGestureConfiguration:
            // The gesture configuration change was accepted.

        case .didFailToWriteGestureConfiguration(let error):
            // The gesture configuration change was rejected with the specified error.

        default:
            break
        }
    }
}
```

## Listening for Sensor Data

The example above showed how to configure the sensors to send data but it did not show how to receive that data. This section and its example will illustrate how that is done.

The `SensorDispatch` class allows you to listen for sensor data. Classes interested in receiving sensor data need to create a `SensorDispatch` instance, specifying which dispatch queue it wants to be notified on. The class then provides the `SensorDispatch` object with a handler object and/or callback blocks to receive the sensor data.

You can have as many `SensorDispatch` instances as you like. They each will receive the same sensor data.

The `SensorDispatchHandler` protocol provides methods for each of the supported sensor types. You can implement the functions corresponding to the sensors of interest to your app in order to receive data from those sensors:

```swift
class ExampleOne: SensorDispatchHandler {

    private let sensorDispatch = SensorDispatch(queue: .main)

    init() {
        sensorDispatch.handler = self
    }

    func receivedAccelerometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        // handle accelerometer reading
    }

    func receivedGyroscope(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        // handle gyroscope reading
    }

    // ...
```

Note that the `SensorDispatchHandler` protocol provides default implementations for all of its methods, so you need only to implement the functions corresponding to the sensors you are interested in.

You can also use callback blocks to receive sensor data:

```swift
class ExampleTwo {

    private let sensorDispatch = SensorDispatch(queue: .main)

    private func startListening() {
        sensorDispatch.accelerometerCallback = { [weak self] (vector, accuracy, timestamp) in
            // handle accelerometer reading
        }

        sensorDispatch.gyroscopeCallback = { [weak self] (vector, accuracy, timestamp) in
            // handle gyroscope reading
        }
    }

    // ...
```

These two approaches are equivalent. Which you use is a matter of preference. You are free to mix the two approaches with the same `SensorDispatch` object. See the documentation for `SensorDispatch` for more details.

## Combined Example

The following class enables the accelerometer and gyroscope sensors as well as the double-tap gesture. It uses a `SensorDispatch` object to receive the data related to those sensors and gestures.

```swift
import BoseWearable

class ExampleClass {

    private let device: WearableDevice

    private var token: ListenerToken?

    private let sensorDispatch = SensorDispatch(queue: .main)

    init(device: WearableDevice) {
        self.device = device

        // Listen for WearableDeviceEvents.
        token = device.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }

        configureSensors()
        configureGestures()
    }

    func configureSensors() {
        device.configureSensors { config in
            // First, disable all currently-enabled sensors.
            config.disableAll()

            // Next, configure the sensors we are interested in.
            config.enable(sensor: .accelerometer, at: ._20ms)
            config.enable(sensor: .gyroscope, at: ._20ms)
        }
    }

    func configureGestures() {
        device.configureGestures { config in
            // First, disable all currently-enabled gestures.
            config.disableAll()

            // Next, configure the gestures we are interested in.
            config.set(gesture: .doubleTap, enabled: true)
        }
    }

    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didUpdateSensorConfiguration:
            // The sensor configuration change was accepted.

        case .didFailToWriteSensorConfiguration(let error):
            // The sensor configuration change was rejected with the specified error.

        case .didUpdateGestureConfiguration:
            // The gesture configuration change was accepted.

        case .didFailToWriteGestureConfiguration(let error):
            // The gesture configuration change was rejected with the specified error.

        default:
            break
        }
    }
}

// NOTE: The SensorDispatchHandler functions are invoked by the SensorDispatch
// on the main queue, as specified in the call to the SensorDispatch initializer.

extension ExampleClass: SensorDispatchHandler {

    func receivedAccelerometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        // handle accelerometer reading
    }

    func receivedGyroscope(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        // handle gyroscope reading
    }

    func receivedGesture(type: GestureType, timestamp: SensorTimestamp) {
        // handle gesture
    }
}
```
