# Bose Wearable SDK Logging

The Bose Wearable SDK uses an internal library called `Logging` which provides convenience wrappers around the native [`OSLog`](https://developer.apple.com/documentation/os/oslog) facilities provided by Apple.

It is recommended to review [Apple's Logging documentation](https://developer.apple.com/documentation/os/logging) as well as [WWDC 2016 Session 721 — Unified Logging and Activity Tracing](https://developer.apple.com/videos/play/wwdc2016/721/) to learn more about the `OSLog` facilities and the terminology used in this document.

The SDK provides two logging subsystems: `com.bose.ar.BLECore` and `com.bose.ar.BoseWearable`. Each subsystem has multiple logging categories.

When initially configuring the Bose Wearable SDK (via `BoseWearable.configure(_:)`), a client application can selectively enable or disable logging for each of the various logging categories. See the documentation for `BoseWearable.ConfigOption` for further details.

While debugging in Xcode, all log messages for enabled categories are shown in the console area. Log are also available in Console.app (found on macOS at `/Applications/Utilities/Console.app`).

In Console.app, select the device in the source list on the left side of the window (you may need to select "Show Sources" from the _View_ menu if the source list is not visible).

In the search bar in the upper-right corner of the window, enter either `subsystem:com.bose.ar.BLECore` or `subsystem:com.bose.ar.BoseWearable`. This will show only messages from the the selected subsystem. You can further filter by category to focus on the information you are interested in. You can enter, for example `category:sensor`, or right-click on a row in the log to modify the filter.

You can select any row in the log to see the complete message at the bottom of the window.

Note that _Info_ and _Debug_ level messages may not be displayed in Console.app. You need to ensure that "Include Info Messages" and "Include Debug Messages" are both checked in the _Action_ menu.
