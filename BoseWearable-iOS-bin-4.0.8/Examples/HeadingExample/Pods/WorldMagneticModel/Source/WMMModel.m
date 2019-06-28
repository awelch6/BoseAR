//
//  WMMModel.m
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

#import "WMMModel.h"

#import "WMMDate.h"
#import "WMMDate+Internal.h"
#import "WMMElements.h"
#import "WMMElements+Internal.h"
#import "WMM/EGM9615.h"
#import "WMM/GeomagnetismHeader.h"

NSErrorDomain const WMMErrorDomain = @"WMMErrorDomain";

@interface WMMModel ()
{
    MAGtype_MagneticModel *magneticModels[1];
    MAGtype_MagneticModel *timedMagneticModel;
    MAGtype_Ellipsoid ellip;
    MAGtype_Geoid geoid;
}

- (MAGtype_CoordGeodetic)geodeticCoordinateFromLocation:(CLLocation *)location altitudeMode:(WMMAltitude)altitudeMode;
@end

@implementation WMMModel

- (nullable instancetype)initWithError:(NSError **)error
{
    if (self = [super init])
    {
        NSString *path = [[NSBundle bundleForClass:[WMMModel class]] pathForResource:@"WMM" ofType:@"COF"];
        if (!MAG_robustReadMagModels((char *)[path cStringUsingEncoding:NSUTF8StringEncoding], &magneticModels, 1))
        {
            NSLog(@"WMM.COF not found");
            if (error)
            {
                *error = [[NSError alloc] initWithDomain:WMMErrorDomain code:WMMErrorCoefficientsNotFound userInfo:nil];
            }
            return nil;
        }

        int nMax = magneticModels[0]->nMax;
        int numTerms = ((nMax + 1) * (nMax + 2) / 2);
        timedMagneticModel = MAG_AllocateModelMemory((numTerms));

        if (magneticModels[0] == nil || timedMagneticModel == nil)
        {
            NSLog(@"Error reading models");
            if (error)
            {
                *error = [[NSError alloc] initWithDomain:WMMErrorDomain code:WMMErrorCannotReadModels userInfo:nil];
            }
            return nil;
        }

        MAG_SetDefaults(&ellip, &geoid);

        geoid.GeoidHeightBuffer = GeoidHeightBuffer;
        geoid.Geoid_Initialized = 1;
    }

    return self;
}

- (MAGtype_CoordGeodetic)geodeticCoordinateFromLocation:(CLLocation *)location altitudeMode:(WMMAltitude)altitudeMode
{
    MAGtype_CoordGeodetic geodetic;

    // CLLocation.altitude is in meters, WMM uses kilometers
    double altitude = location.altitude / 1000;

    geodetic.phi = location.coordinate.latitude;
    geodetic.lambda = location.coordinate.longitude;

    switch (altitudeMode)
    {
        case WMMAltitudeAboveSeaLevel:
            geodetic.HeightAboveGeoid = altitude;
            geodetic.UseGeoid = 1;
            geoid.UseGeoid = 1;
            MAG_ConvertGeoidToEllipsoidHeight(&geodetic, &geoid);
            break;

        case WMMAltitudeAboveWGS84Ellipsoid:
            geodetic.HeightAboveEllipsoid = altitude;
            geodetic.UseGeoid = 0;
            geoid.UseGeoid = 0;
            break;
    }

    return geodetic;
}

- (void)computeForLocation:(nonnull CLLocation *)location
              altitudeMode:(WMMAltitude)altitudeMode
                      date:(nonnull NSDate *)date
                    result:(WMMElements **)result
               uncertainty:(WMMElements **)uncertainty
{
    [self computeForLocation:location
                altitudeMode:altitudeMode
                     wmmDate:[[WMMDate alloc] initWithDate:date]
                      result:result
                 uncertainty:uncertainty];
}

- (void)computeForLocation:(nonnull CLLocation *)location
              altitudeMode:(WMMAltitude)altitudeMode
                   wmmDate:(nonnull WMMDate *)date
                    result:(WMMElements **)result
               uncertainty:(WMMElements **)uncertainty
{
    MAGtype_Date userDate = [date date];
    MAGtype_CoordGeodetic coordGeodetic = [self geodeticCoordinateFromLocation:location altitudeMode:altitudeMode];
    MAGtype_GeoMagneticElements geoMagneticElements, errors;

    MAGtype_CoordSpherical coordSpherical;

    MAG_GeodeticToSpherical(ellip, coordGeodetic, &coordSpherical);
    MAG_TimelyModifyMagneticModel(userDate, magneticModels[0], timedMagneticModel);
    MAG_Geomag(ellip, coordSpherical, coordGeodetic, timedMagneticModel, &geoMagneticElements);
    MAG_CalculateGridVariation(coordGeodetic, &geoMagneticElements);
    MAG_WMMErrorCalc(geoMagneticElements.H, &errors);

    if (result)
    {
        *result = [[WMMElements alloc] initWithElements:geoMagneticElements];
    }

    if (uncertainty)
    {
        *uncertainty = [[WMMElements alloc] initWithElements:errors];
    }
}

- (nonnull WMMElements *)elementsForLocation:(nonnull CLLocation *)location
                                        date:(nonnull NSDate *)date
{
    WMMElements *result = nil;
    [self computeForLocation:location
                altitudeMode:WMMAltitudeAboveSeaLevel
                        date:date
                      result:&result
                 uncertainty:nil];

    return result;
}

- (nonnull WMMElements *)elementsForLocation:(nonnull CLLocation *)location
                                     wmmDate:(nonnull WMMDate *)date
{
    WMMElements *result = nil;
    [self computeForLocation:location
                altitudeMode:WMMAltitudeAboveSeaLevel
                     wmmDate:date
                      result:&result
                 uncertainty:nil];

    return result;
}

- (nonnull WMMElements *)elementsForLocation:(nonnull CLLocation *)location
{
    return [self elementsForLocation:location date:[NSDate date]];
}

@end
