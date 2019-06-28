//
//  WMMDate.m
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

#import "WMMDate.h"
#import "WMMDate+Internal.h"

#import "WMM/GeomagnetismHeader.h"

@interface WMMDate ()
{
    MAGtype_Date date;
}
@end

@implementation WMMDate

- (nullable instancetype)initWithDate:(nonnull NSDate *)date
{
    if (self = [super init])
    {
        NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

        self->date.Year = (int) dc.year;
        self->date.Month = (int) dc.month;
        self->date.Day = (int) dc.day;
        self->date.DecimalYear = 99999;

        char error[255];
        if (!MAG_DateToYear(&self->date, error))
        {
            NSLog(@"Error converting date: %s", error);
            return nil;
        }
    }

    return self;
}

- (nonnull instancetype)initWithDecimalYear:(double)decimalYear
{
    if (self = [super init])
    {
        self->date.DecimalYear = decimalYear;
    }

    return self;
}

- (MAGtype_Date)date
{
    return self->date;
}

@end
