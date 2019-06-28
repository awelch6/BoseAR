# Installation Guide

During the developer preview, the Bose Wearable SDK for iOS is distributed via a zip file. To start, please download the zip file from the Bose Developer Portal.

Regardless of the method used below, you should copy the unzipped contents to your source project. In the examples given below, we will assume you have put the contents of the zip file at `$PROJECT_DIR/Libraries/BoseWearable`, but you may place them anywhere in your source tree. We recommend committing this to source control with the rest of your project.

There are two ways you can integrate the BoseWearable SDK with your app: [CocoaPods](https://cocoapods.org) or manually.

## CocoaPods

To integrate the Bose Wearable SDK into your Xcode project using CocoaPods, add the following to your project's `Podfile`:

```ruby
platform :ios, '11.4'
use_frameworks!

target '<Your Target Name>' do
  pod 'BoseWearable', :path => 'Libraries/BoseWearable'
  pod 'BLECore', :path => 'Libraries/BoseWearable'
  pod 'Logging', :path => 'Libraries/BoseWearable'
end
```

Note, you will need to change the `:path` value to match the installation location you chose above.

Then, run the following command:

```shell
$ pod install
```

## Manual Integration

If you prefer not to use CocoaPods, you can integrate the BoseWearable SDK into your project manually.

- Open the folder in which you place the unzipped distribution above. Drag the `Frameworks` folder into the Project Navigator of your application's Xcode project, dropping it under the target's source folder. In the ensuing sheet, select "Copy items if needed", "Create groups", and select your app target under "Add to targets". This will create the following items in your project:
    - `Frameworks/iOS/BoseWearable.framework`
    - `Frameworks/iOS/BLECore.framework`
    - `Frameworks/iOS/Logging.framework`
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Each of the newly-included `framework` files will appear.
- Select the three frameworks: `BoseWearable.framework`, `BLECore.framework`, and `Logging.framework`.
- Build and run your project to verify this all worked.

> The `BoseWearable` framework and its two companion frameworks are automatically added to Target Dependencies, Link Binary with Libraries, and Embed Frameworks in your app's Build Phases. This is all you need to build and run in the simulator or on a device.

The frameworks included in the manual integration contain code for all supported architectures (x86_64 and arm64). This allows you to run your app in the iOS simulator even though the simulator does not support Bluetooth communication.

A binary that contains the simulator architecture will be rejected by Apple when submitting to the App Store or TestFlight. To remedy this, you need to add a script to your build process that strips unused frameworks from your app's build.

On the "Build Phases" tab of your app target, add a "Run Script" phase with the command:

```shell
bash "${PROJECT_DIR}/Libraries/BoseWearable/bin/strip-frameworks.sh"
```

Check the "Run script only when installing" checkbox.

