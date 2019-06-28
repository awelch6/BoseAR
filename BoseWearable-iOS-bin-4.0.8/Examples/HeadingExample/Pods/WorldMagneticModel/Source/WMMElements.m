//
//  GeomagneticElements.m
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

#import "WMMElements.h"
#import "WMMElements+Internal.h"

#import "WMM/GeomagnetismHeader.h"

@interface WMMElements ()
{
    MAGtype_GeoMagneticElements elements;
}
@end

@implementation WMMElements

- (instancetype)initWithElements:(MAGtype_GeoMagneticElements)elements
{
    if (self = [super init])
    {
        self->elements = elements;
    }
    return self;
}

- (double)decl
{
    return elements.Decl;
}

- (double)incl
{
    return elements.Incl;
}

- (double)f
{
    return elements.F;
}

- (double)h
{
    return elements.H;
}

- (double)x
{
    return elements.X;
}

- (double)y
{
    return elements.Y;
}

- (double)z
{
    return elements.Z;
}

- (double)gv
{
    return elements.GV;
}

- (double)declDot
{
    return elements.Decldot;
}

- (double)inclDot
{
    return elements.Incldot;
}

- (double)fDot
{
    return elements.Fdot;
}

- (double)hDot
{
    return elements.Hdot;
}

- (double)xDot
{
    return elements.Xdot;
}

- (double)yDot
{
    return elements.Ydot;
}

- (double)zDot
{
    return elements.Zdot;
}

- (double)gvDot
{
    return elements.GVdot;
}

@end
