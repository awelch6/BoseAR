//
//  WMMModel.h
//  WorldMagneticModel
//
//  Copyright (c) 2019 Bose Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

@import Foundation;
@import CoreLocation;

#import "WMMAltitude.h"

@class WMMDate;
@class WMMElements;

/**
 World Magnetic Model error domain.
 */
extern NSErrorDomain const WMMErrorDomain;

/**
 World Magnetic Model error.
 */
typedef NS_ERROR_ENUM(WMMErrorDomain, WMMError) {
    
    /** Indicates that the WMM.COF coefficients file could not be found. */
    WMMErrorCoefficientsNotFound,

    /** Indicates that an error occurred when reading the models from file. */
    WMMErrorCannotReadModels
};

@interface WMMModel : NSObject

/**
 Creates a new instance of the World Magnetic Model. Returns `nil` if an error
 occurs while loading the model files.

 @param error Error pointer that is set if an error occurs.
 @return A new instance of the World Magnetic Model, or `nil` if an error occurs.
 */
- (nullable instancetype)initWithError:(NSError **)error NS_SWIFT_NAME(init());

/**
 Computes the magnetic field for the specified location at the specified date.
 The result of this computation is returned via the inout `result` and
 `uncertainty` parameters.

 @param location Compute the magnetic field for this location.
 @param altitudeMode How to interpret the altitude in the specified `location`.
 @param date Compute the magnetic field for this date.
 @param result In-out parameter in which the result of the computation is stored.
 @param uncertainty In-out parameter in which the uncertainty of the result of the computation is stored.
 */
- (void)computeForLocation:(nonnull CLLocation *)location
              altitudeMode:(WMMAltitude)altitudeMode
                      date:(nonnull NSDate *)date
                    result:(WMMElements **)result
               uncertainty:(WMMElements **)uncertainty;

/**
 Computes the magnetic field for the specified location at the specified date.
 The result of this computation is returned via the inout `result` and
 `uncertainty` parameters.

 @param location Compute the magnetic field for this location.
 @param altitudeMode How to interpret the altitude in the specified `location`.
 @param date Compute the magnetic field for this date.
 @param result In-out parameter in which the result of the computation is stored.
 @param uncertainty In-out parameter in which the uncertainty of the result of the computation is stored.
 */
- (void)computeForLocation:(nonnull CLLocation *)location
              altitudeMode:(WMMAltitude)altitudeMode
                   wmmDate:(nonnull WMMDate *)date
                    result:(WMMElements **)result
               uncertainty:(WMMElements **)uncertainty;

/**
 Computes the magnetic field for the specified location at the specified date.
 This is a convenience function that assumes the altitude of the location is
 relative to sea level and that discards the uncertainty value of the
 computation.

 @param location Compute the magnetic field for this location.
 @param date Compute the magnetic field for this date.
 @return The magnetic field elements for the specified location on the specified date.
 */
- (nonnull WMMElements *)elementsForLocation:(nonnull CLLocation *)location
                                        date:(nonnull NSDate *)date;

/**
 Computes the magnetic field for the specified location at the specified date.
 This is a convenience function that assumes the altitude of the location is
 relative to sea level and that discards the uncertainty value of the
 computation.

 @param location Compute the magnetic field for this location.
 @param date Compute the magnetic field for this date.
 @return The magnetic field elements for the specified location on the specified date.
 */
- (nonnull WMMElements *)elementsForLocation:(nonnull CLLocation *)location
                                     wmmDate:(nonnull WMMDate *)date;

/**
 Computes the magnetic field for the specified location at the current date.
 This is a convenience function that assumes the altitude of the location is
 relative to sea level and that discards the uncertainty value of the
 computation.

 @param location Compute the magnetic field for this location at the current date.
 @return The magnetic field elements for the specified location at the current date.
 */
- (nonnull WMMElements *)elementsForLocation:(nonnull CLLocation *)location;

@end
