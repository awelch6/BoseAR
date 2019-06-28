# Sample Code

There are four example projects provided:

- `BasicExample` provides a simple example of how to use the Bose Wearble SDK for iOS.
- `DataExample` provides a comprehensive example of all of the features of the SDK.
- `SceneExample` uses SceneKit to render a 3D model of sunglasses that moves in sync with a connected Bose Wearable device.
- `HeadingExample` provides a simple example of how to determine the user's magnetic heading (relative to the magnetic north pole) and true heading (relative to the geographic north pole) based on a connected Bose Wearable device.

The examples use CocoaPods to integrate the SDK. Instructions to install CocoaPods are available [here](https://github.com/CocoaPods/CocoaPods).

We will build and run `BasicExample` here, but the same instructions hold for the other examples.

Open a Terminal in the root of the SDK distribution. Run the following commands:

```shell
$ cd Examples/BasicExample

$ pod install

$ open BasicExample.xcworkspace
```

Then build and run `BasicExample` in Xcode.

