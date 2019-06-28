#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WMMAltitude.h"
#import "WMMDate.h"
#import "WMMElements.h"
#import "WMMModel.h"
#import "WorldMagneticModel.h"

FOUNDATION_EXPORT double WorldMagneticModelVersionNumber;
FOUNDATION_EXPORT const unsigned char WorldMagneticModelVersionString[];

