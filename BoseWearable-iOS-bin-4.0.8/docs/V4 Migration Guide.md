# Migrating to SDK v4 from v3

This document explains how to migrate from v3 of the Bose Wearable SDK to v4.

## User Interface

Bose provided the `BoseWearable.startDeviceSearch(mode:completionHandler:)` function. It would perform a device search and present UI to the user allowing the selection of a device. This would create a `WearableDeviceSession` and pass it to the completion handler. It was the responsibility of the caller to open the session.

In the v4 SDK, Bose has provided `BoseWearable.startConnection(mode:sensorIntent:gestureIntent:completionHander:)` and deprecated `startDeviceSearch`. This function presents an entirely new user interface for device search. It also guides the user through the secure pairing process, if required. Finally, it checks to see whether a firmware update is available and directs the user to the appropriate app to perform the firmware update. The completion handler is invoked with an open `WearableDeviceSession`, eliminating the requirement to open the session from the client app.

### Continuing to use the v3 API

We encourage all developers to switch over to the new `startConnection` API. The old `startDeviceSearch` API will be removed from a future release of the SDK. If you want to continue using the old `startDeviceSearch` API, you need to handle secure pairing when connecting to devices that require a bonded connection.

To do so, you must register a `WearableDeviceSessionPairingDelegate` instance with the `WearableDeviceSession` before calling `open()`. Failing to do so will result in a fatal error.

When `WearableDeviceSessionPairingDelegate.sessionRequiresPairingMode(_:)` is called, you must present user interface prompting the user to place the device into pairing mode. The process of opening the `WearableDeviceSession` will wait indefinitely for the user to place the device into pairing mode.

When `WearableDeviceSessionPairingDelegate.session(_:finishedPairingWithResult:)` is called, you must dismiss the user interface prompt provided above.

Using `startConnection` in the v4 API handles all of this for you.

### Migrating to the v4 API

Replace your call to `BoseWearable.startDeviceSearch(mode:completionHandler:)` with a call to `BoseWearable.startConnection(mode:sensorIntent:gestureIntent:completionHander:)`. You no longer need to open the session passed to the completion handler when the operation is successful. You do not need to register a `WearableDeviceSessionPairingDelegate` with the `WearableDeviceSession`.

The v3 SDK signalled whether the session successfully opened via the following delegate callbacks:

- `WearableDeviceSessionDelegate.sessionDidOpen(_:)` would indicate that the session successfully opened.
- `WearableDeviceSessionDelegate.session(_:didFailToOpenWithError:)` would indicate that the session failed to open.

The v4 SDK opens the session for you and then performs multiple other operations on the session before passing it to your completion handler. Your completion handler will be invoked with one of the following values:

- `.success(WearableDeviceSession)` indicates that the session opened successfully.
- `.failure(Error)` indicates that the session failed to open, that a firmware update is required, or another error occurred while setting up the session.
- `.cancelled` indicates that the user cancelled the operation.

If you register a `WearableDeviceSessionDelegate` on the `WearableDeviceSession` passed to the completion handler, this delegate's `sessionDidOpen(_:)` and `session(_:didFailToOpenWithError:)` methods will not be invoked in response to the `startConnection` operation. This is because the session has already opened or failed to open before being passed to the completion handler and thus having your delegate registered.

You should continue to register a delegate in order to be notified of a session closing via the `WearableDeviceSessionDelegate.session(_:didCloseWithError:)` function.

If you use `WearableDeviceSession.open()` to attempt to re-open a closed session (e.g., in response to the device disconnecting unexpectedly), you will need to use the `WearableDeviceSessionDelegate` callbacks to be informed of the outcome of that operation.

In summary, on first connection use the completion handler to determine whether the connection succeeded. When reopening a closed session, use the delegate callbacks.

## Euler Angle Conversion

The `Quaternion` type in the SDK provides `pitch`, `roll`, and `yaw` properties that are now deprecated. These return the right-handed rotation around the X, Y, and Z axis, respectively, as defined in the Bose Wearable Coordinate System. However, these only work for the raw Quaternion coming from the device. If calibrating or mapping to a different coordinate system, derive your pitch, roll, and yaw in the new coordinate system from right-handed `Quaternion.xRotation`, `Quaternion.yRotation`, and `Quaternion.zRotation`.

For example:

```swift
let quaternion = /* input received from sensor */

let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
let qResult = quaternion * qMap

let pitch = qResult.xRotation
let roll = qResult.yRotation
let yaw = -qResult.zRotation
```

## Firmware Version

During connection establishment, a check is performed to see whether updated firmware is available. The result of this check is automatically presented to the user when using the `startConnection` API. It is also available via the `WearableDevice.firmwareVersion` property.

The DataExample app shows this information under Device > Firmware Version.

## Suspension

As before, devices may suspend the wearable sensor service. On certain devices, certain user-initiated activities cause the wearable sensor service to be suspended due to bandwidth or processing restrictions.

When the service is suspended, you will continue to be sent a `WearableDeviceEvent.didSuspendWearableSensorService`. In the v4 SDK, this event includes an associated `SuspensionReason` which you can use to inform the user why sensor data is no longer being received.

As before, you will continue to be sent a `WearableDeviceEvent.didResumeWearableSensorService` event when the service resumes.

## Intents

An app may optionally specify a set of sensor and gesture intents that describe which sensors, sample periods, and gestures are required. The SDK provides mechanisms to validate these intents to determine whether a device is compatible with the requirements of your app.

You can optionally provide `SensorIntent` and `GestureIntent` objects to the `startConnection` API to have the intents validated upon connection. If the intents are not met, the connection fails.

Alternatively, you can call `WearableDevice.validateIntents(sensor:gesture:)` after a connection to validate your intents manually.
