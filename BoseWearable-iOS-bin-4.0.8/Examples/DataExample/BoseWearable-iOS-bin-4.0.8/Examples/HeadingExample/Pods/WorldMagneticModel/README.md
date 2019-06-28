# World Magnetic Model

This project provides a native iOS framework that wraps the World Magnetic Model.

The World Magnetic Model is a joint product of the United States’ National Geospatial-Intelligence Agency (NGA) and the United Kingdom’s Defence Geographic Centre (DGC). The WMM was developed jointly by the National Geophysical Data Center (NGDC, Boulder CO, USA) (now the National Centers for Environmental Information (NCEI)) and the British Geological Survey (BGS, Edinburgh, Scotland).

The World Magnetic Model is the standard model used by the U.S. Department of Defense, the U.K. Ministry of Defence, the North Atlantic Treaty Organization (NATO) and the International Hydrographic Organization (IHO), for navigation, attitude and heading referencing systems using the geomagnetic field. It is also used widely in civilian navigation and heading systems. The model, associated software, and documentation are distributed by NCEI on behalf of NGA. The model is produced at 5-year intervals, with the current model expiring on December 31, 2019.

Further information about the World Magnetic Model is available [here](https://www.ngdc.noaa.gov/geomag/WMM/).

The WMM source and coefficients distribution, as downloaded from the WMM website, are included in the `WMM2015v2` directory. These are included here for reference purposes only. Any files used by the iOS wrapper library are also committed under the `Source/WMM` directory.

## Installation

This framework can be installed via [CocoaPods](https://cocoapods.org). Add the following to your `Podfile`:

```ruby
pod 'WorldMagneticModel', '~> 1'
```

## Usage

```swift
import CoreLocation
import WorldMagneticModel

// Step 1: Create the model.
let model = try? WMMModel()

// Step 2: Get the current location of the device. This is left as an exercise
// for the reader.
let location: CLLocation = getCurrentLocation()

// Step 3: Compute the magnetic field elements for the current location at the
// current time.
let elements = model?.elements(for: location)

// Step 4: Get the current heading of the device. This is left as an exercise
// for the reader. The value should be in degrees as the declination value
// (found in WMMElements.decl) is in degrees.
let magneticHeading: Double = getCurrentMagneticHeading()

// Step 5: Use the declination (found in WMMElements.decl) to convert the
// magnetic heading (relative to magnetic north) into a true heading (relative
// to the geographic north).
let trueHeading = magneticHeading + elements.decl
```

