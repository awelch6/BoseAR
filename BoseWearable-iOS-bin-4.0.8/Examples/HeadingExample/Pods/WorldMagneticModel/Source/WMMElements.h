//
//  WMMElements.h
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

#import <Foundation/Foundation.h>

@interface WMMElements : NSObject

/** Angle between the magnetic field fector and true north, positive east. */
@property (nonatomic, readonly, assign) double decl;

/** Angle between the magnetic field vector and the horizontal plane, positive down. */
@property (nonatomic, readonly, assign) double incl;

/** Magnetic field strength. */
@property (nonatomic, readonly, assign) double f;

/** Horizontal magnetic field strength. */
@property (nonatomic, readonly, assign) double h;

/** Northern component of the magnetic field vector. */
@property (nonatomic, readonly, assign) double x;

/** Eastern component of the magnetic field vector. */
@property (nonatomic, readonly, assign) double y;

/** Downward component of the magnetic field vector. */
@property (nonatomic, readonly, assign) double z;

/** The grid variation. */
@property (nonatomic, readonly, assign) double gv;

/** Yearly rate of change in declination. */
@property (nonatomic, readonly, assign) double declDot;

/** Yearly rate of change in inclination. */
@property (nonatomic, readonly, assign) double inclDot;

/** Yearly rate of change in magnetic field strength. */
@property (nonatomic, readonly, assign) double fDot;

/** Yearly rate of change in horizontal field strength. */
@property (nonatomic, readonly, assign) double hDot;

/** Yearly rate of change in the northern component. */
@property (nonatomic, readonly, assign) double xDot;

/** Yearly rate of change in the eastern component. */
@property (nonatomic, readonly, assign) double yDot;

/** Yearly rate of change in the downward component. */
@property (nonatomic, readonly, assign) double zDot;

/** Yearly rate of change in the grid variation. */
@property (nonatomic, readonly, assign) double gvDot;

@end
